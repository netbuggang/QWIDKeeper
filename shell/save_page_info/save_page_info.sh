#!/bin/bash

# 颜色定义 - 只在终端输出时使用
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    PURPLE=''
    NC=''
fi

# 显示使用方法
show_usage() {
    echo -e "${BLUE}使用方法:${NC}"
    echo "  $0 [选项] [文件名]"
    echo ""
    echo -e "${BLUE}选项:${NC}"
    echo "  -h, --help         显示帮助信息"
    echo "  -l, --list         只列出控件ID，不保存文件"
    echo "  -o, --output FILE  指定输出文件名"
    echo "  -t, --timestamp    自动添加时间戳（默认启用）"
    echo "  -c, --no-timestamp 不添加时间戳"
    echo "  -d, --dir DIR      指定保存目录（默认当前目录）"
    echo "  -s, --silent       静默模式，只输出结果"
    echo ""
    echo -e "${BLUE}示例:${NC}"
    echo "  $0                         # 使用默认文件名（带时间戳）"
    echo "  $0 my_page.xml             # 指定文件名（带时间戳）"
    echo "  $0 -c login.xml             # 指定文件名（不带时间戳）"
    echo "  $0 -o home.xml -t           # 指定文件名并带时间戳"
    echo "  $0 -l                       # 只列出控件ID，不保存"
    echo "  $0 -d ./screens login.xml   # 保存到指定目录"
    echo "  $0 --list --silent           # 静默模式只输出控件ID"
}

# 初始化变量
CUSTOM_FILENAME=""
ADD_TIMESTAMP=true
SAVE_DIR="."
LIST_ONLY=false
SILENT_MODE=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -l|--list)
            LIST_ONLY=true
            shift
            ;;
        -s|--silent)
            SILENT_MODE=true
            shift
            ;;
        -c|--no-timestamp)
            ADD_TIMESTAMP=false
            shift
            ;;
        -t|--timestamp)
            ADD_TIMESTAMP=true
            shift
            ;;
        -d|--dir)
            SAVE_DIR="$2"
            shift 2
            ;;
        -o|--output)
            CUSTOM_FILENAME="$2"
            shift 2
            ;;
        -*)
            echo -e "${RED}错误: 未知选项 $1${NC}"
            show_usage
            exit 1
            ;;
        *)
            if [[ -z "$CUSTOM_FILENAME" ]]; then
                CUSTOM_FILENAME="$1"
            else
                echo -e "${RED}错误: 多余的参数 $1${NC}"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# 检查adb是否可用
check_adb() {
    if ! command -v adb &> /dev/null; then
        echo -e "${RED}错误: adb 命令未找到，请安装 Android SDK${NC}"
        exit 1
    fi
    
    DEVICE_COUNT=$(adb devices | grep -c "device$")
    if [[ $DEVICE_COUNT -eq 0 ]]; then
        echo -e "${RED}错误: 没有连接到任何 Android 设备${NC}"
        exit 1
    elif [[ $DEVICE_COUNT -gt 1 ]]; then
        echo -e "${YELLOW}警告: 连接了多个设备，将使用第一个设备${NC}"
        adb devices
        echo ""
    fi
}

# 生成文件名
generate_filename() {
    local base_name="page_info"
    local timestamp_part=""
    
    if [[ "$ADD_TIMESTAMP" == true ]]; then
        timestamp_part="_$(date +"%Y%m%d_%H%M%S")"
    fi
    
    if [[ -n "$CUSTOM_FILENAME" ]]; then
        if [[ "$CUSTOM_FILENAME" == *.* ]]; then
            base_name="${CUSTOM_FILENAME%.*}"
            local ext="${CUSTOM_FILENAME##*.}"
            if [[ "$ADD_TIMESTAMP" == true && "$base_name" != *_*[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]* ]]; then
                echo "${base_name}${timestamp_part}.${ext}"
            else
                echo "$CUSTOM_FILENAME"
            fi
        else
            if [[ "$ADD_TIMESTAMP" == true ]]; then
                echo "${CUSTOM_FILENAME}${timestamp_part}.xml"
            else
                echo "${CUSTOM_FILENAME}.xml"
            fi
        fi
    else
        echo "page_info${timestamp_part}.xml"
    fi
}

# 获取页面信息 - 修复版本
get_page_info() {
    local temp_file="/sdcard/temp_dump_$$.xml"
    local final_filename="$1"
    local full_path="${SAVE_DIR}/${final_filename}"
    
    # 创建保存目录
    if [[ ! -d "$SAVE_DIR" ]]; then
        mkdir -p "$SAVE_DIR"
    fi
    
    # 输出信息到 stderr，这样不会被变量捕获
    if [[ "$SILENT_MODE" == false ]]; then
        echo -e "${BLUE}正在获取当前页面信息...${NC}" >&2
    fi
    
    # 执行 uiautomator dump
    if ! adb shell uiautomator dump "$temp_file" > /dev/null 2>&1; then
        echo -e "${RED}错误: 无法获取页面信息${NC}" >&2
        exit 1
    fi
    
    # 拉取文件到电脑
    if ! adb pull "$temp_file" "$full_path" > /dev/null 2>&1; then
        echo -e "${RED}错误: 无法拉取文件${NC}" >&2
        adb shell rm "$temp_file"
        exit 1
    fi
    
    # 删除临时文件
    adb shell rm "$temp_file"
    
    if [[ "$SILENT_MODE" == false ]]; then
        echo -e "${GREEN}✓ 页面信息已保存到: ${full_path}${NC}" >&2
    fi
    
    # 只返回文件路径，不返回其他内容
    echo "$full_path"
}

# 分析XML文件
analyze_xml() {
    local xml_file="$1"
    
    if [[ ! -f "$xml_file" ]]; then
        echo "错误: 文件 $xml_file 不存在" >&2
        return 1
    fi
    
    if [[ "$SILENT_MODE" == false ]]; then
        echo -e "\n${BLUE}📱 页面分析结果:${NC}" >&2
        echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    fi
    
    # 提取所有控件ID
    local ids=$(grep -o 'resource-id="[^"]*"' "$xml_file" | sed 's/resource-id="//g' | sed 's/"//g' | sort -u)
    local id_count=$(echo "$ids" | grep -v '^$' | wc -l | tr -d ' ')
    
    if [[ "$SILENT_MODE" == false ]]; then
        echo -e "${YELLOW}发现 $id_count 个控件ID:${NC}" >&2
    fi
    
    if [[ $id_count -gt 0 ]]; then
        if [[ "$SILENT_MODE" == false ]]; then
            echo "$ids" | while read id; do
                if [[ -n "$id" ]]; then
                    echo -e "  ${GREEN}•${NC} $id" >&2
                fi
            done
        else
            # 静默模式输出到 stdout
            echo "$ids" | grep -v '^$'
        fi
    else
        if [[ "$SILENT_MODE" == false ]]; then
            echo -e "  ${YELLOW}未找到任何控件ID${NC}" >&2
        fi
    fi
    
    if [[ "$SILENT_MODE" == false ]]; then
        echo -e "\n${YELLOW}其他统计信息:${NC}" >&2
        
        local clickable=$(grep -c 'clickable="true"' "$xml_file")
        echo -e "  • 可点击元素: ${GREEN}$clickable${NC}" >&2
        
        local edittext=$(grep -c 'class="android.widget.EditText"' "$xml_file")
        echo -e "  • 输入框: ${GREEN}$edittext${NC}" >&2
        
        local button=$(grep -c 'class="android.widget.Button"' "$xml_file")
        echo -e "  • 按钮: ${GREEN}$button${NC}" >&2
        
        local text=$(grep -c 'class="android.widget.TextView"' "$xml_file")
        echo -e "  • 文本标签: ${GREEN}$text${NC}" >&2
        
        echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
        
        local file_size=$(du -h "$xml_file" 2>/dev/null | cut -f1)
        if [[ -n "$file_size" ]]; then
            echo -e "${BLUE}文件大小: ${file_size}${NC}" >&2
        fi
    fi
}

# 主函数
main() {
    check_adb
    
    if [[ "$LIST_ONLY" == true ]]; then
        local temp_file="/sdcard/temp_list_$$.xml"
        if [[ "$SILENT_MODE" == false ]]; then
            echo -e "${BLUE}正在获取当前页面控件ID...${NC}" >&2
        fi
        
        adb shell uiautomator dump "$temp_file" > /dev/null 2>&1
        adb pull "$temp_file" "/tmp/temp_list.xml" > /dev/null 2>&1
        adb shell rm "$temp_file"
        
        if [[ "$SILENT_MODE" == false ]]; then
            echo -e "${GREEN}当前页面的控件ID:${NC}" >&2
        fi
        
        grep -o 'resource-id="[^"]*"' "/tmp/temp_list.xml" | sed 's/resource-id="//g' | sed 's/"//g' | sort -u
        rm "/tmp/temp_list.xml"
        exit 0
    fi
    
    local filename=$(generate_filename)
    local saved_file=$(get_page_info "$filename")
    
    # 确保文件存在再分析
    if [[ -f "$saved_file" ]]; then
        analyze_xml "$saved_file"
    else
        echo "错误: 文件 $saved_file 不存在" >&2
        exit 1
    fi
}

# 运行主函数
main

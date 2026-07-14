#!/bin/bash

# ==============================================================================
# Step 1: Initialization & Solid Block Banner
# ==============================================================================

# ==============================================================================
# PROJECT: Universal CMS Version Checker (WordPress, Joomla, Drupal)
# AUTHOR: Mahdi Ahazan
# GITHUB: https://github.com/MahdiAhazan/CMS-Version-Checker
# ==============================================================================

START_TIME=$(date +%s)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Output File Configuration
REPORT_TXT="cms_report_$TIMESTAMP.txt"
REPORT_JSON="cms_report_$TIMESTAMP.json"
REPORT_HTML="cms_report_$TIMESTAMP.html"

# Initialize temporal stream buffers
TMP_JSON_STREAM=$(mktemp)

# 1. Display Clean Block ASCII Banner in Terminal (Fully Fixed)
clear
echo -e "\e[36m"
echo "███╗   ███╗ █████╗ ██╗  ██╗██████╗ ██╗        █████╗ ██╗  ██╗ █████╗ ███████╗ █████╗ ███╗   ██╗"
echo "████╗ ████║██╔══██╗██║  ██║██╔══██╗██║       ██╔══██╗██║  ██║██╔══██╗╚══███╔╝██╔══██╗████╗  ██║"
echo "██╔████╔██║███████║███████║██║  ██║██║       ███████║███████║███████║  ███╔╝ ███████║██╔██╗ ██║"
echo "██║╚██╔╝██║██╔══██║██╔══██║██║  ██║██║       ██╔══██║██╔══██║██╔══██║ ███╔╝  ██╔══██║██║╚██╗██║"
echo "██║ ╚═╝ ██║██║  ██║██║  ██║██████╔╝██║       ██║  ██║██║  ██║██║  ██║███████╗██║  ██║██║ ╚████║"
echo "╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝"
echo -e "\e[0m"
echo -e "\e[1;34m==============================================================================================\e[0m"
echo -e "\e[1;32m Developed by: Mahdi Ahazan\e[0m"
echo -e "\e[1;32m Project URL : https://github.com/MahdiAhazan/CMS-Version-Checker\e[0m"
echo -e "\e[1;34m==============================================================================================\e[0m"
echo ""

# Write TXT Log File Header
cat << EOF > "$REPORT_TXT"
======================================================================
 SERVER CMS SCAN REPORT (UNIVERSAL CHECKER)
======================================================================
Developed By : Mahdi Ahazan
Project Link : https://github.com/MahdiAhazan/CMS-Version-Checker
Scan Started : $(date)
======================================================================

EOF

wp_count=0; j_count=0; d_count=0; total_count=0
echo -n "Initializing engine scan... Discovered: 0"


# ==============================================================================
# Step 2: The Core Scanning Loop & JSON Assembly Line
# ==============================================================================

# Scan and pipe properties cleanly to a temporary streaming database
find / -maxdepth 7 -type f \( -name "version.php" -o -name "Version.php" -o -name "system.info.yml" -o -name "system.info" \) 2>/dev/null | while read -r file; do
    if [[ "$file" == *"/components/"* || "$file" == *"/administrator/components/"* || "$file" == *"/modules/"* || "$file" == *"/plugins/"* || "$file" == *"/templates/"* || "$file" == *"/node_modules/"* || "$file" == *"/vendor/"* ]]; then
        continue
    fi
    
    # --- WordPress ---
    if [[ "$file" == *"/wp-includes/version.php" ]]; then
        wp_ver=$(awk -F"'" '/\$wp_version *= */{print $2}' "$file" 2>/dev/null)
        if [ ! -z "$wp_ver" ]; then
            path="${file%/wp-includes/version.php}"
            echo "[WordPress] Version: $wp_ver | Path: $path" >> "$REPORT_TXT"
            echo "{\"cms\":\"WordPress\",\"version\":\"$wp_ver\",\"path\":\"$path\"}," >> "$TMP_JSON_STREAM"
            ((wp_count++)); ((total_count++))
            echo -ne "\rScanning deployment nodes... Discovered: $total_count (WP: $wp_count | Joomla: $j_count | Drupal: $d_count)"
        fi
        
    # --- Joomla ---
    elif [[ "$file" == *"/Version.php" || "$file" == *"/version.php" ]] && [[ "$file" != *"/wp-includes/"* ]]; then
        if [[ "$file" == *"/libraries/src/Version.php" || "$file" == *"/libraries/joomla/version.php" || "$file" == *"/libraries/cms/version.php" || "$file" == *"/libraries/cms/version/version.php" || "$file" == *"/includes/version.php" ]]; then
            j_version=""
            if grep -q "MAJOR_VERSION" "$file" 2>/dev/null; then
                j_major=$(grep -w "MAJOR_VERSION" "$file" | head -n1 | tr -dc '0-9')
                j_minor=$(grep -w "MINOR_VERSION" "$file" | head -n1 | tr -dc '0-9')
                j_patch=$(grep -w "PATCH_VERSION" "$file" | head -n1 | tr -dc '0-9')
                [ ! -z "$j_major" ] && j_version="${j_major}.${j_minor:-0}.${j_patch:-0}"
            fi
            if [ -z "$j_version" ]; then
                j_rel=$(sed -n "s/.*RELEASE.*['\"]\(.*\)['\"].*/\1/p" "$file" | tr -d '[:space:]')
                j_dev=$(sed -n "s/.*DEV_LEVEL.*['\"]\(.*\)['\"].*/\1/p" "$file" | tr -d '[:space:]')
                [ -z "$j_rel" ] && j_rel=$(sed -n "s/.*\$RELEASE.*=\s*\(.*\);/\1/p" "$file" | tr -d "';\" ")
                [ -z "$j_dev" ] && j_dev=$(sed -n "s/.*\$DEV_LEVEL.*=\s*\(.*\);/\1/p" "$file" | tr -d "';\" ")
                if [ ! -z "$j_rel" ]; then j_version="${j_rel}.${j_dev:-0}"; fi
            fi
            if [ ! -z "$j_version" ]; then
                path="${file%/[Vv]ersion.php}"
                path="${path%/libraries/src}"; path="${path%/libraries/joomla}"; path="${path%/libraries/cms/version}"; path="${path%/libraries/cms}"; path="${path%/includes}"
                echo "[Joomla] Version: $j_version | Path: $path" >> "$REPORT_TXT"
                echo "{\"cms\":\"Joomla\",\"version\":\"$j_version\",\"path\":\"$path\"}," >> "$TMP_JSON_STREAM"
                ((j_count++)); ((total_count++))
                echo -ne "\rScanning deployment nodes... Discovered: $total_count (WP: $wp_count | Joomla: $j_count | Drupal: $d_count)"
            fi
            unset j_version j_major j_minor j_patch
        fi
        
    # --- Drupal Modern (8+) ---
    elif [[ "$file" == *"/core/modules/system/system.info.yml" ]]; then
        d_path="${file%/core/modules/system/system.info.yml}"
        d_ver_clean=$(awk '/^version:/{gsub(/['"'"'"]/,""); print $2}' "$file" 2>/dev/null | tr -d '[:space:]' | tr -cd '[:print:]')
        if [ -z "$d_ver_clean" ] || [[ "$d_ver_clean" == *"VERSION"* ]]; then
            drupal_php_file="$d_path/core/lib/Drupal.php"
            if [ -f "$drupal_php_file" ]; then
                d_ver_clean=$(grep "const VERSION" "$drupal_php_file" | head -n1 | awk -F"'" '{print $2}' | tr -d '[:space:]')
                [ -z "$d_ver_clean" ] && d_ver_clean=$(grep "const VERSION" "$drupal_php_file" | head -n1 | awk -F'"' '{print $2}' | tr -d '[:space:]')
            fi
        fi
        [ -z "$d_ver_clean" ] && d_ver_clean="Detected (Core 8+)"
        echo "[Drupal] Version: $d_ver_clean | Path: $d_path" >> "$REPORT_TXT"
        echo "{\"cms\":\"Drupal\",\"version\":\"$d_ver_clean\",\"path\":\"$d_path\"}," >> "$TMP_JSON_STREAM"
        ((d_count++)); ((total_count++))
        echo -ne "\rScanning deployment nodes... Discovered: $total_count (WP: $wp_count | Joomla: $j_count | Drupal: $d_count)"
        unset d_path d_ver_clean
        
    # --- Drupal Legacy (<8) ---
    elif [[ "$file" == *"/modules/system/system.info" ]]; then
        d_path="${file%/modules/system/system.info}"
        d_ver=$(awk -F'"' '/^version *= */{print $2}' "$file" 2>/dev/null)
        [ -z "$d_ver" ] && d_ver=$(awk -F"'" '/^version *= */{print $2}' "$file" 2>/dev/null)
        [ -z "$d_ver" ] && d_ver="Detected (Core <8)"
        d_ver_clean=$(echo "$d_ver" | tr -d "';\" " | tr -cd '[:print:]')
        echo "[Drupal] Version: $d_ver_clean | Path: $d_path" >> "$REPORT_TXT"
        echo "{\"cms\":\"Drupal\",\"version\":\"$d_ver_clean\",\"path\":\"$d_path\"}," >> "$TMP_JSON_STREAM"
        ((d_count++)); ((total_count++))
        echo -ne "\rScanning deployment nodes... Discovered: $total_count (WP: $wp_count | Joomla: $j_count | Drupal: $d_count)"
        unset d_path d_ver_clean
    fi
done

END_TIME=$(date +%s)
EXEC_TIME=$((END_TIME - START_TIME))

# ==============================================================================
# Step 3: Core Discovery Loop & High-Speed Multi-CMS Version Parsing
# ==============================================================================

# Initialize temporary data streaming buffer for XML mapping
TMP_XML_STREAM=$(mktemp)

# Start scanning the server using process substitution to prevent subshell variable isolation.
# It safe-skips massive system directories to scan custom subdomains at maximum speed.
while read -r file; do
    # Global filter to skip theme, extension, vendor, and component configuration files
    if [[ "$file" == *"/components/"* || "$file" == *"/administrator/components/"* || "$file" == *"/modules/"* || "$file" == *"/plugins/"* || "$file" == *"/templates/"* || "$file" == *"/node_modules/"* || "$file" == *"/vendor/"* ]]; then
        continue
    fi
    
    # --- WordPress Engine Parser ---
    if [[ "$file" == *"/wp-includes/version.php" ]]; then
        wp_ver=$(awk -F"'" '/\$wp_version *= */{print $2}' "$file" 2>/dev/null)
        if [ ! -z "$wp_ver" ]; then
            path="${file%/wp-includes/version.php}"
            echo "[WordPress] Version: $wp_ver | Path: $path" >> "$REPORT_TXT"
            echo "    <website><cms_type>WordPress</cms_type><version>$wp_ver</version><path>$path</path></website>" >> "$TMP_XML_STREAM"
            ((wp_count++)); ((total_count++))
            echo -ne "\rScanning deployment nodes... Discovered: $total_count (WP: $wp_count | Joomla: $j_count | Drupal: $d_count)"
        fi
        
    # --- Joomla Engine Parser (All Generations: 1.5 up to 6+) ---
    elif [[ "$file" == *"/Version.php" || "$file" == *"/version.php" ]] && [[ "$file" != *"/wp-includes/"* ]]; then
        if [[ "$file" == *"/libraries/src/Version.php" || "$file" == *"/libraries/joomla/version.php" || "$file" == *"/libraries/cms/version.php" || "$file" == *"/libraries/cms/version/version.php" || "$file" == *"/includes/version.php" ]]; then
            j_version=""
            # Parse modern object-oriented Joomla class constants (J4, J5, J6)
            if grep -q "MAJOR_VERSION" "$file" 2>/dev/null; then
                j_major=$(grep -w "MAJOR_VERSION" "$file" | head -n1 | tr -dc '0-9')
                j_minor=$(grep -w "MINOR_VERSION" "$file" | head -n1 | tr -dc '0-9')
                j_patch=$(grep -w "PATCH_VERSION" "$file" | head -n1 | tr -dc '0-9')
                [ ! -z "$j_major" ] && j_version="${j_major}.${j_minor:-0}.${j_patch:-0}"
            fi
            # Fallback to extract legacy Joomla variable representations (J1.5, J2.5, J3)
            if [ -z "$j_version" ]; then
                j_rel=$(sed -n "s/.*RELEASE.*['\"]\(.*\)['\"].*/\1/p" "$file" | tr -d '[:space:]')
                j_dev=$(sed -n "s/.*DEV_LEVEL.*['\"]\(.*\)['\"].*/\1/p" "$file" | tr -d '[:space:]')
                [ -z "$j_rel" ] && j_rel=$(sed -n "s/.*\$RELEASE.*=\s*\(.*\);/\1/p" "$file" | tr -d "';\" ")
                [ -z "$j_dev" ] && j_dev=$(sed -n "s/.*\$DEV_LEVEL.*=\s*\(.*\);/\1/p" "$file" | tr -d "';\" ")
                if [ ! -z "$j_rel" ]; then j_version="${j_rel}.${j_dev:-0}"; fi
            fi
            if [ ! -z "$j_version" ]; then
                path="${file%/[Vv]ersion.php}"
                path="${path%/libraries/src}"; path="${path%/libraries/joomla}"; path="${path%/libraries/cms/version}"; path="${path%/libraries/cms}"; path="${path%/includes}"
                echo "[Joomla] Version: $j_version | Path: $path" >> "$REPORT_TXT"
                echo "    <website><cms_type>Joomla</cms_type><version>$j_version</version><path>$path</path></website>" >> "$TMP_XML_STREAM"
                ((j_count++)); ((total_count++))
                echo -ne "\rScanning deployment nodes... Discovered: $total_count (WP: $wp_count | Joomla: $j_count | Drupal: $d_count)"
            fi
            unset j_version j_major j_minor j_patch
        fi
        
    # --- Modern Drupal Parser (Drupal 8, 9, 10, 11+) ---
    elif [[ "$file" == *"/core/modules/system/system.info.yml" ]]; then
        d_path="${file%/core/modules/system/system.info.yml}"
        d_ver_clean=$(awk '/^version:/{gsub(/['"'"'"]/,""); print $2}' "$file" 2>/dev/null | tr -d '[:space:]' | tr -cd '[:print:]')
        # Check composer runtime configurations if the version parameter tag is empty inside info.yml
        if [ -z "$d_ver_clean" ] || [[ "$d_ver_clean" == *"VERSION"* ]]; then
            drupal_php_file="$d_path/core/lib/Drupal.php"
            if [ -f "$drupal_php_file" ]; then
                d_ver_clean=$(grep "const VERSION" "$drupal_php_file" | head -n1 | awk -F"'" '{print $2}' | tr -d '[:space:]')
                [ -z "$d_ver_clean" ] && d_ver_clean=$(grep "const VERSION" "$drupal_php_file" | head -n1 | awk -F'"' '{print $2}' | tr -d '[:space:]')
            fi
        fi
        [ -z "$d_ver_clean" ] && d_ver_clean="Detected (Core 8+)"
        echo "[Drupal] Version: $d_ver_clean | Path: $d_path" >> "$REPORT_TXT"
        echo "    <website><cms_type>Drupal</cms_type><version>$d_ver_clean</version><path>$d_path</path></website>" >> "$TMP_XML_STREAM"
        ((d_count++)); ((total_count++))
        echo -ne "\rScanning deployment nodes... Discovered: $total_count (WP: $wp_count | Joomla: $j_count | Drupal: $d_count)"
        unset d_path d_ver_clean
        
    # --- Legacy Drupal Parser (Drupal 6 & 7) ---
    elif [[ "$file" == *"/modules/system/system.info" ]]; then
        d_path="${file%/modules/system/system.info}"
        d_ver=$(awk -F'"' '/^version *= */{print $2}' "$file" 2>/dev/null)
        [ -z "$d_ver" ] && d_ver=$(awk -F"'" '/^version *= */{print $2}' "$file" 2>/dev/null)
        [ -z "$d_ver" ] && d_ver="Detected (Core <8)"
        d_ver_clean=$(echo "$d_ver" | tr -d "';\" " | tr -cd '[:print:]')
        echo "[Drupal] Version: $d_ver_clean | Path: $d_path" >> "$REPORT_TXT"
        echo "    <website><cms_type>Drupal</cms_type><version>$d_ver_clean</version><path>$d_path</path></website>" >> "$TMP_XML_STREAM"
        ((d_count++)); ((total_count++))
        echo -ne "\rScanning deployment nodes... Discovered: $total_count (WP: $wp_count | Joomla: $j_count | Drupal: $d_count)"
        unset d_path d_ver_clean
    fi
# scanning the entire server by removing annoying system folders
done < <(find / -maxdepth 7 \( -path "/proc" -o -path "/sys" -o -path "/dev" -o -path "/var/log" -o -path "/var/mail" -o -path "/home/*/mail" \) -prune -o -type f \( -name "version.php" -o -name "Version.php" -o -name "system.info.yml" -o -name "system.info" \) 2>/dev/null)

END_TIME=$(date +%s)
EXEC_TIME=$((END_TIME - START_TIME))

# ==============================================================================
# 4. Generate Pre-Compiled Standalone HTML Visual Dashboard (With Retained Counters Scope)
# ==============================================================================

TMP_HTML_ROWS=$(mktemp)

if [ -f "$REPORT_TXT" ]; then
    grep -E "\[WordPress\]|\[Joomla\]|\[Drupal\]" "$REPORT_TXT" | while read -r line; do
        cms_name=$(echo "$line" | awk -F'[][]' '{print $2}')
        cms_version=$(echo "$line" | awk -F'Version: ' '{print $2}' | awk -F' |' '{print $1}')
        cms_path=$(echo "$line" | awk -F'Path: ' '{print $2}')
        
        echo "            <tr>" >> "$TMP_HTML_ROWS"
        echo "                <td><span class=\"cms-badge cms-$cms_name\">$cms_name</span></td>" >> "$TMP_HTML_ROWS"
        echo "                <td><strong>$cms_version</strong></td>" >> "$TMP_HTML_ROWS"
        echo "                <td><span class=\"path-text\">$cms_path</span></td>" >> "$TMP_HTML_ROWS"
        echo "            </tr>" >> "$TMP_HTML_ROWS"
    done
fi

cat << EOF > "$REPORT_HTML"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Server CMS Scan Report - Mahdi Ahazan</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Arial, sans-serif; background-color: #f4f6f9; margin: 30px; color: #333; direction: ltr; }
        .header-box { background: #2c3e50; color: #fff; padding: 25px; border-radius: 6px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); margin-bottom: 25px; }
        .header-box h2 { margin: 0 0 10px 0; font-size: 24px; }
        .header-box a { color: #3498db; text-decoration: none; font-weight: bold; }
        .summary-container { display: flex; gap: 15px; margin-bottom: 25px; }
        .summary-card { flex: 1; background: #fff; padding: 15px; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); text-align: center; border-bottom: 4px solid #bdc3c7; }
        .card-wp { border-bottom-color: #27ae60; }
        .card-joomla { border-bottom-color: #2980b9; }
        .card-drupal { border-bottom-color: #8e44ad; }
        .card-total { border-bottom-color: #f39c12; }
        .stat-num { font-size: 22px; font-weight: bold; margin-top: 5px; }
        table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 6px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        th, td { padding: 12px 15px; text-align: left; font-size: 14px; }
        th { background-color: #34495e; color: #fff; font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; }
        tr { border-bottom: 1px solid #edf2f7; }
        tr:hover { background-color: #f8fafc; }
        .cms-badge { padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; text-transform: uppercase; color: #fff; }
        .cms-WordPress { background-color: #27ae60; }
        .cms-Joomla { background-color: #2980b9; }
        .cms-Drupal { background-color: #8e44ad; }
        .path-text { color: #4a5568; font-family: monospace; font-size: 13px; background: #edf2f7; padding: 2px 6px; border-radius: 4px; }
        .footer { text-align: center; margin-top: 40px; font-size: 12px; color: #7f8c8d; border-top: 1px solid #dcdde1; padding-top: 15px; }
    </style>
</head>
<body>
    <div class="header-box">
        <h2>Server Universal CMS Scan Report</h2>
        <div>Scan Orchestrated by <strong>Mahdi Ahazan</strong> "CMS Version Checker" Component Utilities.</div>
        <div style="margin-top: 8px; font-size: 13px;">Project Repository: <a href="https://github.com/MahdiAhazan/CMS-Version-Checker" target="_blank">GitHub Codebase Link</a></div>
    </div>

    <div class="summary-container">
        <div class="summary-card card-total"><div>Total Discovered</div><div class="stat-num">$total_count</div></div>
        <div class="summary-card card-wp"><div>WordPress</div><div class="stat-num">$wp_count</div></div>
        <div class="summary-card card-joomla"><div>Joomla</div><div class="stat-num">$j_count</div></div>
        <div class="summary-card card-drupal"><div>Drupal</div><div class="stat-num">$d_count</div></div>
    </div>
    
    <table>
        <thead>
            <tr>
                <th width="15%">Platform</th>
                <th width="15%">Engine Version</th>
                <th width="70%">Deployment Path</th>
            </tr>
        </thead>
        <tbody>
EOF

# Inject the processed row markers
cat "$TMP_HTML_ROWS" >> "$REPORT_HTML"
rm -f "$TMP_HTML_ROWS"

cat << EOF >> "$REPORT_HTML"
        </tbody>
    </table>

    <div class="footer">
        Generated automatically via CMS Version Checker Analytics (Mahdi Ahazan). Engine Execution Time: $EXEC_TIME seconds.
    </div>
</body>
</html>
EOF

# Compile and clean JSON data syntax tracking arrays
echo "{" > "$REPORT_JSON"
echo "  \"developer\": \"Mahdi Ahazan\"," >> "$REPORT_JSON"
echo "  \"github_repository\": \"https://github.com/MahdiAhazan/CMS-Version-Checker"," >> "$REPORT_JSON"
echo "  \"scan_date\": \"$(date)\"," >> "$REPORT_JSON"
echo "  \"execution_time_seconds\": $EXEC_TIME," >> "$REPORT_JSON"
echo "  \"statistics\": {" >> "$REPORT_JSON"
echo "    \"wordpress_count\": $wp_count," >> "$REPORT_JSON"
echo "    \"joomla_count\": $j_count," >> "$REPORT_JSON"
echo "    \"drupal_count\": $d_count," >> "$REPORT_JSON"
echo "    \"total_discovered\": $total_count" >> "$REPORT_JSON"
echo "  }," >> "$REPORT_JSON"
echo "  \"websites\": [" >> "$REPORT_JSON"

if [ -s "$TMP_JSON_STREAM" ]; then
    sed '$ s/,$//' "$TMP_JSON_STREAM" >> "$REPORT_JSON"
fi
rm -f "$TMP_JSON_STREAM"

echo "  ]" >> "$REPORT_JSON"
echo "}" >> "$REPORT_JSON"

# Append Statistics Footer metrics onto plain text log tracker
cat << EOF >> "$REPORT_TXT"

======================================================================
 SCAN METRICS & TOTAL STATISTICS
======================================================================
Total WordPress Instances : $wp_count
Total Joomla Instances    : $j_count
Total Drupal Instances    : $d_count
Total Platforms Found     : $total_count
Scan Concluded At         : $(date)
Total Execution Timeline  : $EXEC_TIME seconds
======================================================================
Generated via Mahdi Ahazan Open-Source Systems Toolkit.
Project URL: https://github.com/MahdiAhazan/CMS-Version-Checker
======================================================================
EOF

# Final Success Terminal Message 
echo -e "\n\n\e[32m[✔] Server Analytics Complete\e[0m"
echo -e " -> Plain Text Registry Data : \e[1;34m$REPORT_TXT\e[0m"
echo -e " -> Developer JSON Dataset   : \e[1;35m$REPORT_JSON\e[0m"
echo -e " -> Standalone HTML Panel    : \e[1;36m$REPORT_HTML\e[0m"
echo ""

🇮🇷 **برای مطالعه راهنمای فارسی این پروژه، [اینجا را کلیک کنید](README.fa.md).**
# Universal CMS Version Checker (WordPress, Joomla, Drupal)

A high-speed, structural, and control-panel-agnostic shell script engineered for Linux Server Administrators (cPanel, DirectAdmin, Plesk, or standalone servers). It deeply scans the entire global filesystem to uncover active Content Management System deployments and map their core version metrics.

## ✨ Key Features
- **Solid ASCII Banner Art:** Features an perfectly formatted terminal-wide visual signature of the author upon launch.
- **Full-Generation Joomla Parsing:** Decodes legacy variables (J1.5 to J3) and natively handles modern object-oriented core class constants (J4, J5, and Joomla 6+).
- **Subdomain-Aware Architecture:** Since it loops from the server root (`/`), it discovers all isolated websites deployed outside the standard `public_html` directory structure.
- **Anti-Subshell Scope Engine:** Implements advanced `Process Substitution` logic to guarantee that dashboard numeric counters update accurately and never zero out.
- **High-Velocity File Filtering:** Leverages precise directory pruning (`-prune`) to skip massive OS folders, core logs, and backup emails—improving execution speed up to 10x.
- **Triple Synchronous Output Delivery (Protects History Logs):**
  1. **Plain Text Logs (`.txt`):** Time-stamped, classic configuration mapping files for rapid terminal view.
  2. **Developer-Ready Arrays (`.json`):** Compliant, raw data schema ready to interface with central backend apps or custom cPanel/DirectAdmin UI plugins.
  3. **Standalone UI Dashboards (`.html`):** A pre-compiled, highly responsive web display featuring color-coded status elements. It opens flawlessly in any local browser without running into CORS security blockers.

## 🛠️ Installation & Quick Start

### 1. Create the Script Workspace
Log into your terminal via SSH as `root` and generate the execution file:
```bash
nano cms_scanner.sh
```
*(Paste the combined 4-step codebase here, hit `Ctrl+O` to save configurations, and clear with `Ctrl+X`).*

### 2. Configure Local Execute Clearances
Modify file permissions across the operational Linux layer:
```bash
chmod +x cms_scanner.sh
```

### 3. Deploy Server-Wide Automation
Run the routine natively inside your operational path:
```bash
./cms_scanner.sh
```

## 📊 File Architecture Breakdown

Upon completion, the engine drops 3 custom timestamped outputs right into your current workspace:

- **`cms_report_YYYYMMDD_HHMMSS.txt`:** Plain text configuration mappings detailing target paths.
- **`cms_report_YYYYMMDD_HHMMSS.json`:** Structured payload elements ready for panel integration logic.
- **`cms_report_YYYYMMDD_HHMMSS.html`:** The standalone web panel. Simply download it to your local desktop and open it inside Google Chrome, Firefox, Safari, or Edge to access the responsive analytical charts visually.

---
**Developed By:** Mahdi Ahazan  
**Official Repository:** [https://github.com/MahdiAhazan/CMS-Version-Checker](https://github.com/MahdiAhazan/CMS-Version-Checker)

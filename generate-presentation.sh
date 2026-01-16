#!/bin/bash

# Script to generate multiple presentation formats from Marp markdown
# Usage: ./generate-presentation.sh <input-file.md>

set -e

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Error: No input file provided"
    echo "Usage: $0 <input-file.md>"
    exit 1
fi

INPUT_FILE="$1"
BASENAME="${INPUT_FILE%.md}"
OUTPUT_DIR="${BASENAME}_output"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found"
    exit 1
fi

# Check if marp is installed
if ! command -v marp &> /dev/null; then
    echo "Error: marp CLI is not installed"
    echo "Install it with: npm install -g @marp-team/marp-cli"
    exit 1
fi

echo "Creating output directory: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo ""
echo "Generating presentations from: $INPUT_FILE"
echo "============================================"

# 1. Generate HTML
echo ""
echo "[1/5] Generating HTML..."
marp "$INPUT_FILE" -o "$OUTPUT_DIR/${BASENAME}.html"
echo "✓ HTML generated: $OUTPUT_DIR/${BASENAME}.html"

# 2. Generate PDF with speaker notes
echo ""
echo "[2/5] Generating PDF with speaker notes..."
marp "$INPUT_FILE" --pdf --pdf-notes --allow-local-files -o "$OUTPUT_DIR/${BASENAME}_with_notes.pdf"
echo "✓ PDF with notes generated: $OUTPUT_DIR/${BASENAME}_with_notes.pdf"

# 3. Generate PDF without speaker notes
echo ""
echo "[3/5] Generating PDF without speaker notes..."
marp "$INPUT_FILE" --pdf --allow-local-files -o "$OUTPUT_DIR/${BASENAME}_no_notes.pdf"
echo "✓ PDF without notes generated: $OUTPUT_DIR/${BASENAME}_no_notes.pdf"

# 4. Generate PPTX with speaker notes (default behavior)
echo ""
echo "[4/5] Generating PPTX with speaker notes..."
marp "$INPUT_FILE" --pptx --allow-local-files -o "$OUTPUT_DIR/${BASENAME}_with_notes.pptx"
echo "✓ PPTX with notes generated: $OUTPUT_DIR/${BASENAME}_with_notes.pptx"

# 5. Generate PPTX without speaker notes
echo ""
echo "[5/5] Generating PPTX without speaker notes..."
# Create temporary file without speaker notes in the same directory as input
INPUT_DIR=$(dirname "$INPUT_FILE")
TEMP_FILE="${INPUT_DIR}/.temp_${BASENAME}_no_notes.md"
grep -v '^<!--' "$INPUT_FILE" | sed '/^<!--/,/-->$/d' > "$TEMP_FILE"
marp "$TEMP_FILE" --pptx --allow-local-files -o "$OUTPUT_DIR/${BASENAME}_no_notes.pptx"
rm "$TEMP_FILE"
echo "✓ PPTX without notes generated: $OUTPUT_DIR/${BASENAME}_no_notes.pptx"

echo ""
echo "============================================"
echo "All presentations generated successfully!"
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "Files created:"
echo "  - ${BASENAME}.html"
echo "  - ${BASENAME}_with_notes.pdf"
echo "  - ${BASENAME}_no_notes.pdf"
echo "  - ${BASENAME}_with_notes.pptx"
echo "  - ${BASENAME}_no_notes.pptx"

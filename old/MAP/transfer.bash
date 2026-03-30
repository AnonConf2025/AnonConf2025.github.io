for f in *.pdf; do
    base="${f%.pdf}"
    pdf2svg "$f" "${base}.svg"
done
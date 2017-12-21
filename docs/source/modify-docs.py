#change link to auth design file
newLines = []
with open("components/authService.md", "r") as f:
    for line in f:
        newLines.append(line.replace("(DESIGN.md)", 
"(authServiceDesign.html)"));

with open("components/authService.md", 'w') as f:
    for line in newLines:
        f.write(line);

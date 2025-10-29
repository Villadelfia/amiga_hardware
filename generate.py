from box import Box

# Load all the data.
data = Box.from_toml(filename="data.toml")
inner = []
for section in data.sections:
    inner.append(Box.from_toml(filename=f"{section}.toml"))
data.sections = inner
lines = []
spacer = 8

def comment_line(comment):
    out = f"*** {comment} "
    if len(out) < 80:
        out += "*" * (80-len(out))
    return [out]

def format_comment(prefix, comment, continuation_prefix=""):
    out = []
    comment = comment.split(" ")
    while len(comment) > 0:
        line = prefix
        while len(comment) > 0 and len(line + comment[0]) <= 80:
            line += comment.pop(0) + " "
        out.append(line[:-1])
        prefix = continuation_prefix if continuation_prefix != "" else prefix
    return out

# Header.
guard = str(data.output).upper().replace(".", "_")
lines += [f"%%IFND {guard}"]
lines += [f"{guard}%%SET 1"]
spacer = max(spacer, len(guard)+1)

# Info-box
lines += ["**"]
lines += format_comment("**  ", data.header)
lines += ["**"]
lines += ["**  Sections:"]
for section in data.sections:
    lines += format_comment("**    - ", section.title + ": " + section.short_info, "**      ")
lines += ["**"]
lines += ["*" * 80]

# The rest of the sections.
for section in data.sections:
    if not "sections" in section: continue
    for s in section.sections:
        if "chipset" in s and s.chipset != data.chipset: continue
        lines += [""]
        lines += comment_line(s.name)
        if s.type != "line":
            # Block sections are one big formatted comment.
            lines += ["*"]
            pushedempty = False
            for line in s.comment.split("\n"):
                if line != "":
                    pushedempty = False
                    lines += format_comment("*   ", line)
                else:
                    pushedempty = True
                    lines += ["*"]
            if pushedempty:
                lines.pop()
            
            didnothing = False
            if s.type == "kv":
                for kvs in s.kv:
                    if not didnothing: lines += ["*"]
                    didnothing = True
                    for kv in kvs:
                        if "c" in kv and kv.c != data.chipset: continue
                        lines += [f"{kv.k}%%= {kv.v}"]
                        spacer = max(spacer, len(kv.k)+1)
                        didnothing = False

            if not didnothing: lines += ["*"]
            lines += ["*" * 80]


# Footer.
lines += ["%%ENDC"]

# Post-process spacing.
for i in range(len(lines)):
    if not "%%" in lines[i]: continue
    spaceridx = lines[i].index("%%")
    lines[i] = lines[i].replace("%%", " " * (spacer - spaceridx))
print("\n".join(lines))
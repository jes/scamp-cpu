extern print;
extern printnum;

print("sp="); printnum(*0xffff); print("\n");
print("Hello, world!\n");
print("sp="); printnum(*0xffff); print("\n");

extern print;
extern printnum;

var sp = 0xffff;

print("sp="); printnum(*sp); print("\n");
print("Hello, world!\n");
print("sp="); printnum(*sp); print("\n");

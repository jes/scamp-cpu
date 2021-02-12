extern print;
extern printnum;

var _sp = 0xffff;

print("sp="); printnum(*_sp); print("\n");
print("Hello, world!\n");
print("sp="); printnum(*_sp); print("\n");

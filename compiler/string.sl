# return a value:
#  <0  if s1 < s2
#   0  if s1 == s2
#  >0  if s1 > s2
extern strcmp;

var strlen = func(s) {
    var ss = s;
    while (*ss) ss++;
    return ss - s;
};

var memset = func(s, val, len) {
    var ss = s;
    while (len--) *(s++) = val;
    return ss;
};

var memcpy = func(dest, src, len) {
    var dd = dest;
    while (len--) *(dest++) = *(src++);
    return dd;
};

var strcpy = func(dest, src) {
    var dd = dest;
    while (*src) *(dest++) = *(src++);
    *dest = 0;
    return dd;
};

var strdup = func(s) {
    var ss = malloc(strlen(s)+1);
    strcpy(ss, s);
    return ss;
};

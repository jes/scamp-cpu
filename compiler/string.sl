# return a value:
#  <0  if s1 < s2
#   0  if s1 == s2
#  >0  if s1 > s2
var strcmp = func(s1, s2) {
    while (*s1 && *s2) {
        if (*s1 != *s2)
            return *s1-*s2;
        s1++;
        s2++
    };

    if (*s1 != *s2)
        return *s1-*s2;
    return 0;
};

var strlen = func(s) {
    var ss = s;
    while (*ss) ss++;
    return ss - s;
};

var memset = func(s, val, len) {
    var ss = s;
    while (len--) {
        *(s++) = val;
    };
    return ss;
};

var strcpy = func(dest, src) {
    var dd = dest;
    while (*src)
        *(dest++) = *(src++);
    return dd;
};

var strdup = func(s) {
    var ss = malloc(strlen(s)+1);
    strcpy(ss, s);
    return ss;
};

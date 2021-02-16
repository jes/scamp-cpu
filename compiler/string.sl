# return a value:
#  <0  if s1 < s2
#   0  if s1 == s2
#  >0  if s1 > s2
var strcmp = func(s1, s2) {
    while (*s1 && *s2) {
        if (*s1 != *s2)
            return *s1-*s2;
        s1 = s1 + 1;
        s2 = s2 + 1;
    };

    if (*s1 != *s2)
        return *s1-*s2;
    return 0;
};

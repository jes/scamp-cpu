# Singly-linked list
#
# A list consists of a head element pointer and a tail element pointer.
# An element consists of a value and a next element pointer.
#
# TODO: [perf] make it doubly-linked so that lstpop() is O(1)?
# TODO: [nice] insert element at given index
# TODO: [nice] retrieve element at given index
# TODO: [nice] delete element at given index

include "malloc.sl";

# return a pointer to the empty list
var lstnew = func() {
    return cons(0,0);
};

var lsthead = car;
var lstsethead = setcar;
var lsttail = cdr;
var lstsettail = setcdr;

var elemnew = func(v) {
    return cons(v,0);
};

var elemval = car;
var elemsetval = setcar;
var elemnext = cdr;
var elemsetnext = setcdr;

var elemfree = free;

var lstfree = func(lst) {
    var elem = lsthead(lst);
    var next;
    free(lst);

    while (elem) {
        next = elemnext(elem);
        elemfree(elem);
        elem = next;
    };
};

# append the given value to the end of the list
# O(1)
var lstpush = func(lst, v) {
    var new_elem = elemnew(v);
    var tail_elem = lsttail(lst);

    if (tail_elem) elemsetnext(tail_elem, new_elem)
    else lstsethead(lst,new_elem);

    lstsettail(lst, new_elem);
};

# remove the last value from the list and return it
# return 0 if the list is empty
# O(n) (!)
var lstpop = func(lst) {
    var head = lsthead(lst);
    var tail = lsttail(lst);
    if (!tail) return 0;
    var val = elemval(tail);
    var elem;

    if (head == tail) {
        # list becomes empty
        lstsethead(lst, 0);
        lstsettail(lst, 0);
    } else {
        # find the second-last element
        elem = head;
        while (elemnext(elem) != tail)
            elem = elemnext(elem);

        elemsetnext(elem, 0);
        lstsettail(lst, elem);
    };

    elemfree(tail);
    return val;
};

# prepend the given value to the start of the list
# O(1)
var lstunshift = func(lst, v) {
    var new_elem = elemnew(v);
    var head_elem = lsthead(lst);

    elemsetnext(new_elem, head_elem);
    lstsethead(lst, new_elem);
};

# remove the first value from the list and return it
# return 0 if the list is empty
var lstshift = func(lst) {
    var head = lsthead(lst);
    if (!head) return 0;
    var val = elemval(head);

    lstsethead(lst, elemnext(head));
    if (!lsthead(lst)) lstsettail(lst, 0); # tail=0 if head=0

    elemfree(head);
    return val;
};

# O(n)
var lstlen = func(lst) {
    var elem = lsthead(lst);
    var len = 0;

    while (elem) {
        elem = elemnext(elem);
        len++;
    };

    return len;
};

# call cb() on each value in the list
var lstwalk = func(lst, cb) {
    var elem = lsthead(lst);

    while (elem) {
        cb(elemval(elem));
        elem = elemnext(elem);
    };
};

# call cb(findval, val) on each value in the list
# if cb(findval, val) returns nonzero, break the loop and return val
# return 0 if the value is not found
var lstfind = func(lst, findval, cb) {
    var elem = lsthead(lst);
    var val;

    while (elem) {
        val = elemval(elem);
        if (cb(findval, val)) return val;
        elem = elemnext(elem);
    };

    return 0;
};

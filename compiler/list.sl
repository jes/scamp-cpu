# Singly-linked list
#
# A list consists of a head element pointer and a tail element pointer.
# An element consists of a value and a next element pointer.
#
# TODO: make it doubly-linked so that lstpop() is O(1)?
# TODO: insert element at given index
# TODO: retrieve element at given index
# TODO: delete element at given index

# return a pointer to the empty list
var lstnew = func() {
    var lst = malloc(2);
    *lst = 0; # head
    *(lst+1) = 0; # tail
    return lst;
};

# return a pointer to the first element of the list
var lsthead = func(lst) { return *lst; };
# return a pointer to the last element of the list
var lsttail = func(lst) { return *(lst+1); };

var elemnew = func(v) {
    var el = malloc(2);
    *el = v;
    *(el+1) = 0;
    return el;
};

# return the value of the given element
var elemval = func(elem) { return *elem; };
# return the next element of the given element
var elemnext = func(elem) { return *(elem+1); };

var elemfree = func(elem) {
    free(elem);
};

var lstfree = func(lst) {
    var elem = lsthead(lst);
    var next;
    free(lst);

    while (elem) {
        next = elemnext(elem);
        free(elem);
        elem = next;
    };
};

# append the given value to the end of the list
# O(1)
var lstpush = func(lst, v) {
    var new_elem = elemnew(v);
    var tail_elem = lsttail(lst);

    if (tail_elem) *(tail_elem+1) = new_elem
    else *lst = new_elem;

    *(lst+1) = new_elem; # tail = new
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
        *lst = 0;
        *(lst+1) = 0;
    } else {
        # find the second-last element
        elem = head;
        while (elemnext(elem) != tail)
            elem = elemnext(elem);

        *(elem+1) = 0;
        *(lst+1) = elem;
    };

    elemfree(tail);
    return val;
};

# prepend the given value to the start of the list
# O(1)
var lstunshift = func(lst, v) {
    var new_elem = elemnew(v);
    var head_elem = lsthead(lst);

    *(new_elem+1) = head_elem;
    *lst = new_elem;
};

# remove the first value from the list and return it
# return 0 if the list is empty
var lstshift = func(lst) {
    var head = lsthead(lst);
    if (!head) return 0;
    var val = elemval(head);

    *lst = elemnext(head);
    if (!*lst) *(lst+1) = 0; # tail=0 if head=0

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

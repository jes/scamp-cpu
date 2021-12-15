# min-heap
# based on the broken example at https://www.educative.io/blog/data-structure-heaps-guide
#
# h[0] = comparator
# h[1] = grarr

include "grarr.sl";

var heapnew = func(cmp) {
	var h = malloc(2);
	h[0] = cmp;
	h[1] = grnew();
	return h;
};

var heapfree = func(h) {
	grfree(h[1]);
	free(h);
};

var heaplen = func(h) {
	return grlen(h[1]);
};

var _heappercolateup = func(h, index) {
	var parent;
	var cmp = h[0];
	var gr = h[1];
	var t;
	while (index) {
		parent = div(index-1,2);

		# if "index" and "parent" are already in the right order, do nothing
		if (cmp(grget(gr,parent), grget(gr,index)) < 0) return 0;

		# otherwise, swap index and parent, and step up a level
		t = grget(gr,parent);
		grset(gr,parent, grget(gr,index));
		grset(gr,index, t);

		index = parent;
	};
};

var _heapify = func(h, index) {
	var cmp = h[0];
	var gr = h[1];
	var left;
	var right;
	var min;
	var t;
	while (1) {
		left = index+index+1;
		right = left+1;
		min = index;
		if (grlen(gr) > left)
			if (cmp(grget(gr,min), grget(gr,left)) > 0)
				min = left;
		if (grlen(gr) > right)
			if (cmp(grget(gr,min), grget(gr,right)) > 0)
				min = right;
		if (min == index) return 0;

		t = grget(gr, min);
		grset(gr, min, grget(gr, index));
		grset(gr, index, t);
		index = min;
	};
};

# insert element v into heap h
var heappush = func(h, v) {
	grpush(h[1], v);
	_heappercolateup(h, grlen(h[1])-1);
};

# remove the minimum element from the heap and return it, or 0 if none
var heappop = func(h) {
	var gr = h[1];
	var min;
	if (grlen(gr) > 1) {
		min = grget(gr, 0);
		grset(gr, 0, grpop(gr));
		_heapify(h, 0);
		return min;
	} else if (grlen(gr) == 1) {
		return grpop(gr);
	} else {
		return 0;
	};
};

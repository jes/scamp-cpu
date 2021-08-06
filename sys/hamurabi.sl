# Ported from https://www.atariarchives.org/basicgames/showpage.php?page=79
# (mirrored in doc/hamurabi.png)

include "stdio.sl";
include "stdlib.sl";
include "malloc.sl";

# TODO: [nice] better rand(), srand(), move to stdlib.sl
var randstate = 0x5a7f;
var rand = func() {
    randstate = mul(randstate, 17) + 0x2e7;
    return randstate;
};

var mismanagement;
var thinkgrain;
var thinkacres;
var calcC;
var solong;

# read a number from stdin
var input = func() {
    puts("? ");
    var buf = malloc(256);
    if (!gets(buf,256)) solong();
    var n = atoi(buf);
    if (n < 0) {
        printf("\nHAMURABI:  I CANNOT DO WHAT YOU WISH.\n",0);
        printf("GET YOURSELF ANOTHER STEWARD!!!!!\n",0);
        solong();
    };
    return n;
};

printf("                                HAMURABI\n",0);
printf("               CREATIVE COMPUTING  MORRISTOWN, NEW JERSEY\n",0);
printf("\n\n\n",0);
printf("TRY YOUR HAND AT GOVERNING ANCIENT SUMERIA\n",0);
printf("FOR A TEN-YEAR TERM OF OFFICE.\n",0);
printf("\n",0);

var D1=0; var P1=0;
var Z=0; var P=95; var S=2800; var H=3000; var E=H-S;
var Y=3; var A=div(H,Y); var I=5; var Q=1;
var D=0;

var C;

var main = func() {
    while (1) {
        printf("\n\n",0);
        printf("HAMURABI:  I BEG TO REPORT TO YOU,\n",0);
        Z=Z+1;
        printf("IN YEAR %d, %d PEOPLE STARVED, %d CAME TO THE CITY,\n", [Z,D,I]);
        P=P+I;
        if (Q<=0) {
            P = div(P,2);
            printf("A HORRIBLE PLAGUE STRUCK!  HALF THE PEOPLE DIED.\n", 0);
        };
        printf("POPULATION IS NOW %d\n", [P]);
        printf("THE CITY NOW OWNS %d ACRES.\n", [A]);
        printf("YOU HARVESTED %d BUSHELS PER ACRE.\n", [Y]);
        printf("RATS ATE %d BUSHELS.\n", [E]);
        printf("YOU NOW HAVE %d BUSHELS IN STORE.\n\n", [S]);
        if (Z==11) break;
        C=mod(rand(),10); Y=C+17;
        printf("LAND IS TRADING AT %d BUSHELS PER ACRE.\n", [Y]);
        while (1) {
            printf("HOW MANY ACRES DO YOU WISH TO BUY",0);
            Q=input();
            if (mul(Y,Q) <= S) break;
            thinkgrain();
        };
        if (Q) {
            A=A+Q; S=S-mul(Y,Q); C=0;
        } else {
            while (1) {
                printf("HOW MANY ACRES DO YOU WITH TO SELL",0);
                Q=input();
                if (Q < A) break;
                thinkacres();
            };
            A=A-Q; S=S+mul(Y,Q); C=0;
        };
        printf("\n",0);
        while (1) {
            printf("HOW MANY BUSHELS DO YOU WISH TO FEED YOUR PEOPLE",0);
            Q=input();
            # *** TRYING TO USE MORE GRAIN THAN IS IN SILOS?
            if (Q <= S) break;
            thinkgrain();
        };
        S=S-Q; C=1;
        printf("\n",0);
        while (1) {
            printf("HOW MANY ACRES DO YOU WISH TO PLANT WITH SEED",0);
            D=input();
            # *** TRYING TO PLANT MORE ACRES THAN YOU OWN?
            if (D <= A) {
                # *** ENOUGH GRAIN FOR SEED?
                if (div(D,2) <= S) {
                    # *** ENOUGH PEOPLE TO TEND THE CROPS?
                    if (D < mul(10,P)) break;
                    printf("BUT YOU HAVE ONLY %d PEOPLE TO TEND THE FIELDS!  NOW THEN,\n",[P]);
                } else {
                    thinkgrain();
                };
            } else {
                thinkacres();
            };
        };
        S=S-div(D,2);
        calcC();
        # *** A BOUNTIFUL HARVEST!
        Y=C; H=mul(D,Y); E=0;
        calcC();
        if (C&1 == 0) {
            # *** RATS ARE RUNNING WILD!!
            E=div(S,C);
        };
        S=S-E+H;
        calcC();
        # *** LET'S HAVE SOME BABIES
        I = div(div(mul(C,mul(20,A)+S),P),100) + 1;
        # *** HOW MANY PEOPLE HAD FULL TUMMIES?
        C=div(Q,20);
        # *** HORROR, A 15% CHANCE OF PLAGUE
        Q=mod(rand(),100)-15;
        if (P<C) {
            D=0;
            continue;
        };
        # *** STARVE ENOUGH FOR IMPEACHMENT?
        D=P-C;
        if (mul(D,100) > mul(45,P)) {
            printf("\n\n",0);
            printf("YOU STARVED %d PEOPLE IN ONE YEAR!!!\n",[D]);
            mismanagement();
        };
        P1=div(div(mul(Z-1,P1)+mul(D,100),P),Z);
        P=C; D1=D1+D;
    };

    printf("IN YOUR 10-YEAR TERM OF OFFICE, %d PERCENT OF THE\n",[P1]);
    printf("POPULATION STARVED PER YEAR ON THE AVERAGE, I.E. A TOTAL OF\n",0);
    printf("%d PEOPLE DIED!!\n",[D]);
    var L=div(A,P);
    printf("YOU STARTED WITH 10 ACRES PER PERSON AND ENDED WITH\n",0);
    printf("%d ACRES PER PERSON.\n", [L]);
    printf("\n",0);
    if (P1>33 || L<7) {
        mismanagement();
    } else if (P1>10 || L<9) {
        printf("YOUR HEAVY-HANDED PERFORMANCE SMACKS OF NERO AND IVAN IV.\n",0);
        printf("THE PEOPLE (REMAINING) FIND YOU AN UNPLEASANT RULER, AND,\n",0);
        printf("FRANKLY, HATE YOUR GUTS!!\n",0);
    } else if (P1>3 || L<10) {
        printf("YOUR PERFORMANCE COULD HAVE BEEN SOMEWHAT BETTER, BUT\n",0);
        printf("REALLY WASN'T TOO BAD AT ALL.  %d PEOPLE\n", [div((mul(P,mod(rand(),80))),100)]);
        printf("DEARLY LIKE TO SEE YOU ASSASSINATED BUT WE ALL HAVE OUR\n",0);
        printf("TRIVIAL PROBLEMS.\n",0);
    } else {
        printf("A FANTASTIC PERFORMANCE!!!  CHARLEMAGNE, DISRAELI, AND\n",0);
        printf("JEFFERSON COMBINED COULD NOT HAVE DONE BETTER!\n",0);
    };
    solong();
};

mismanagement = func() {
    printf("DUE TO THIS EXTREME MISMANAGEMENT YOU HAVE NOT ONLY\n",0);
    printf("BEEN IMPEACHED AND THROWN OUT OF OFFICE BUT YOU HAVE\n",0);
    printf("ALSO BEEN DECLARED NATIONAL FINK!!!!\n",0);
    solong();
};

thinkgrain = func() {
    printf("HAMURABI:  THINK AGAIN. YOU HAVE ONLY\n",0);
    printf("%d BUSHELS OF GRAIN.  NOW THEN,\n",[S]);
};

thinkacres = func() {
    printf("HAMURABI:  THINK AGAIN. YOU OWN ONLY %d ACRES.  NOW THEN,\n",[A]);
};

calcC = func() {
    C=mod(rand(),5)+1;
};

solong = func() {
    printf("\n",0);
    printf("SO LONG FOR NOW.\n",0);
    exit(0);
};

main();

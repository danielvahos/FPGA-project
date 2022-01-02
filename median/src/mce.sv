module mce(a, b, max, min);
    input logic [7:0] a;
    input logic [7:0] b;

    output logic [7:0] max;
    output logic [7:0] min;

    assign max = (a>=b)? a:b;
    assign min = (a<b)? a:b;

endmodule:mce

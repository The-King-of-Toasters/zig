const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");

pub extern fn __muloti4(a: i128, b: i128, overflow: *c_int) i128 {
    @setRuntimeSafety(builtin.is_test);

    const min = @bitCast(i128, u128(1 << (i128.bit_count - 1)));
    const max = ~min;
    overflow.* = 0;

    const r = a *% b;
    if (a == min) {
        if (b != 0 and b != 1) {
            overflow.* = 1;
        }
        return r;
    }
    if (b == min) {
        if (a != 0 and a != 1) {
            overflow.* = 1;
        }
        return r;
    }

    const sa = a >> (i128.bit_count - 1);
    const abs_a = (a ^ sa) -% sa;
    const sb = b >> (i128.bit_count - 1);
    const abs_b = (b ^ sb) -% sb;

    if (abs_a < 2 or abs_b < 2) {
        return r;
    }

    if (sa == sb) {
        if (abs_a > @divTrunc(max, abs_b)) {
            overflow.* = 1;
        }
    } else {
        if (abs_a > @divTrunc(min, -abs_b)) {
            overflow.* = 1;
        }
    }

    return r;
}

const v128 = @Vector(2, u64);
pub extern fn __muloti4_windows_x86_64(a: v128, b: v128, overflow: *c_int) v128 {
    return @bitCast(v128, @inlineCall(__muloti4, @bitCast(i128, a), @bitCast(i128, b), overflow));
}

test "import muloti4" {
    _ = @import("muloti4_test.zig");
}

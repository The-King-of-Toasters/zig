// Ported from:
//
// https://github.com/llvm/llvm-project/blob/2ffb1b0413efa9a24eb3c49e710e36f92e2cb50b/compiler-rt/lib/builtins/modti3.c

const udivmod = @import("udivmod.zig").udivmod;
const builtin = @import("builtin");
const compiler_rt = @import("../compiler_rt.zig");

pub extern fn __modti3(a: i128, b: i128) i128 {
    @setRuntimeSafety(builtin.is_test);

    const s_a = a >> (i128.bit_count - 1); // s = a < 0 ? -1 : 0
    const s_b = b >> (i128.bit_count - 1); // s = b < 0 ? -1 : 0

    const an = (a ^ s_a) -% s_a; // negate if s == -1
    const bn = (b ^ s_b) -% s_b; // negate if s == -1

    var r: u128 = undefined;
    _ = udivmod(u128, @bitCast(u128, an), @bitCast(u128, bn), &r);
    return (@bitCast(i128, r) ^ s_a) -% s_a; // negate if s == -1
}

const v128 = @Vector(2, u64);
pub extern fn __modti3_windows_x86_64(a: v128, b: v128) v128 {
    return @bitCast(v128, @inlineCall(__modti3, @bitCast(i128, a), @bitCast(i128, b)));
}

test "import modti3" {
    _ = @import("modti3_test.zig");
}

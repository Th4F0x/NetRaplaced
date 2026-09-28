pub const @"build.IntLen" = enum (u2) {
    u16 = 0,
    u32 = 1,
    u64 = 2,
    usize = 3,
};
pub const intlen: @"build.IntLen" = .u32;

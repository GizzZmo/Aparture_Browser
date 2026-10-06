mod sandbox;

pub use sandbox::{is_within, resolve_within, SandboxError};

/// File index and AI tool schemas land in later slices.
pub fn slice() -> u8 {
    2
}

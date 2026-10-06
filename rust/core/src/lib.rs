mod index;
mod sandbox;

pub use index::Index;
pub use sandbox::{is_within, resolve_within, SandboxError};

pub fn slice() -> u8 {
    3
}

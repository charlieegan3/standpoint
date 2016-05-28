#[macro_export]
macro_rules! try_opt_clone {
    ($expr:expr) => (match $expr {
        ::std::option::Option::Some(ref val) => val.clone(),
        ::std::option::Option::None => return None
    })
}

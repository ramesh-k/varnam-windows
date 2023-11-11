#![allow(clippy::missing_safety_doc)]

use std::fs::File;
use std::io::prelude::*;

use crate::parser::find_items;

pub struct TableDictionaryEngine {
    content: String,
}

impl TableDictionaryEngine {
    pub fn load(path: &str) -> Result<TableDictionaryEngine, std::io::Error> {
        let mut content = String::new();
        File::open(path)?.read_to_string(&mut content)?;
        Ok(TableDictionaryEngine { content })
    }

    pub unsafe fn from_void(ptr: *mut core::ffi::c_void) -> Box<TableDictionaryEngine> {
        Box::from_raw(ptr as *mut TableDictionaryEngine)
    }

    pub fn collect_word(&self, search_key: &str) -> Vec<(String, String)> {
        let mut vec = find_items(&self.content[..], search_key, false, false);
        vec.sort_by(|x, y| x.0.cmp(&y.0));
        vec
    }

    pub fn collect_word_for_wildcard(&self, search_key: &str) -> Vec<(String, String)> {
        let mut vec = find_items(&self.content[..], search_key, false, true);
        vec.sort_by(|x, y| x.0.cmp(&y.0));
        vec
    }

    pub fn collect_word_from_converted_string_for_wildcard(
        &self,
        search_key: &str,
    ) -> Vec<(String, String)> {
        let mut vec = find_items(&self.content[..], search_key, true, true);
        vec.sort_by(|x, y| x.0.cmp(&y.0));
        vec
    }
}

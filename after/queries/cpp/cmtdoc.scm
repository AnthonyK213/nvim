(enum_specifier
  name: (type_identifier) @name
  (#set! "kind" "enum")) @type

(struct_specifier
  name: (type_identifier) @name
  body: (field_declaration_list)?
  (#set! "kind" "struct")) @type

(class_specifier
  name: (type_identifier) @name
  (#set! "kind" "class")) @type

((function_declarator
   declarator: (_) @name
   parameters: (parameter_list) @params) @type
 (#has-ancestor? @type function_definition field_declaration declaration)
 (#set! "kind" "func_decl"))

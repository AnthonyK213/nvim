(enum_declaration
  name: (identifier) @name
  (#set! "kind" "enum")) @type

(interface_declaration
  name: (identifier) @name
  (#set! "kind" "interface")) @type

(struct_declaration
  name: (identifier) @name
  (#set! "kind" "struct")) @type

(class_declaration
  name: (identifier) @name
  (#set! "kind" "class")) @type

(constructor_declaration
  (modifier)*
  name: (identifier) @name
  parameters: (parameter_list) @params
  (#set! "kind" "function")) @type

(method_declaration
  (modifier)*
  returns: (_) @returns
  name: (identifier) @name
  parameters: (parameter_list) @params
  (#set! "kind" "function")) @type

(local_function_statement
  (modifier)*
  type: (_) @returns
  name: (identifier) @name
  parameters: (parameter_list) @params
  (#set! "kind" "function")) @type

(property_declaration
  name: (identifier) @name
  (#set! "kind" "property")) @type

(field_declaration
  (variable_declaration
    (variable_declarator
      (identifier) @name))
  (#set! "kind" "field")) @type

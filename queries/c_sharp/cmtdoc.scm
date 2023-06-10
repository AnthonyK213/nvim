(interface_declaration
  name: (identifier) @name
  (#set! "kind" "interface")) @type

(class_declaration
  name: (identifier) @name
  (#set! "kind" "class")) @type

(struct_declaration
  name: (identifier) @name
  (#set! "kind" "Struct")) @type

(method_declaration
  name: (identifier) @name
  (#set! "kind" "Method")) @type

(enum_declaration
  name: (identifier) @name
  (#set! "kind" "Enum")) @type

(constructor_declaration
  name: (identifier) @name
  (#set! "kind" "Constructor")) @type

(property_declaration
  name: (identifier) @name
  (#set! "kind" "Property")) @type

(field_declaration
   (variable_declaration
    (variable_declarator
       (identifier) @name))
  (#set! "kind" "Field")) @type

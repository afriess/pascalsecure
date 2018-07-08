// we compile in mode objfpc with RTTI activated

{$mode objfpc}{$H+}{$M+}   // TYPEINFO ON

// Standard is to build both Levelschema and Authschema, its for debugging
{$define UseLevelSchema}
{$define UseAuthSchema}

// ******************* Debugging **********************
// Debugging with a lot of infos
//   can be used in projectoption / custom options as -ddebug_secure
{.$define debug_secure}

//   can be used in projectoption / custom options as -dDebugLevelSchemaOnly
{$ifdef DebugLevelSchemaOnly}
  {$define debug_secure}
  {$undef UseAuthSchema}
  {$HINT Debug Levelbased Schema only}
{$endif}
{$ifdef DebugAuthSchemaOnly}
  {$define debug_secure}
  {$undef UseLevelSchema}
  {$HINT Debug Authbased Schema only}
{$endif}




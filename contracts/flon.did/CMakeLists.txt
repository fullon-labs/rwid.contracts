add_contract(flon.did flon.did ${CMAKE_CURRENT_SOURCE_DIR}/src/flon.did.cpp)

target_include_directories(flon.did
   PUBLIC
   ${CMAKE_CURRENT_SOURCE_DIR}/include)

set_target_properties(flon.did
   PROPERTIES
   RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/ricardian/flon.did.contracts.md.in ${CMAKE_CURRENT_BINARY_DIR}/ricardian/flon.did.contracts.md @ONLY )

target_compile_options( flon.did PUBLIC -R${CMAKE_CURRENT_SOURCE_DIR}/ricardian -R${CMAKE_CURRENT_BINARY_DIR}/ricardian )

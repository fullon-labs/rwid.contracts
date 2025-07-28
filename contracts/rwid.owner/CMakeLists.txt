add_contract(rwid.owner rwid.owner ${CMAKE_CURRENT_SOURCE_DIR}/src/rwid.owner.cpp)

target_include_directories(rwid.owner
   PUBLIC
   ${CMAKE_CURRENT_SOURCE_DIR}/include)

set_target_properties(rwid.owner
   PROPERTIES
   RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/ricardian/rwid.owner.contracts.md.in ${CMAKE_CURRENT_BINARY_DIR}/ricardian/rwid.owner.contracts.md @ONLY )

target_compile_options( rwid.owner PUBLIC -R${CMAKE_CURRENT_SOURCE_DIR}/ricardian -R${CMAKE_CURRENT_BINARY_DIR}/ricardian )

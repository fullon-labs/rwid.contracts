add_contract(rwid.auth rwid.auth ${CMAKE_CURRENT_SOURCE_DIR}/src/rwid.auth.cpp)

target_include_directories(rwid.auth
   PUBLIC
   ${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_SOURCE_DIR}/../flon.bootdao/include)

set_target_properties(rwid.auth
   PROPERTIES
   RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/ricardian/rwid.auth.contracts.md.in ${CMAKE_CURRENT_BINARY_DIR}/ricardian/rwid.auth.contracts.md @ONLY )

target_compile_options( rwid.auth PUBLIC -R${CMAKE_CURRENT_SOURCE_DIR}/ricardian -R${CMAKE_CURRENT_BINARY_DIR}/ricardian )

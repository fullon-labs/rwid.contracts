add_contract(rwid.dao rwid.dao ${CMAKE_CURRENT_SOURCE_DIR}/src/rwid.dao.cpp)

target_include_directories(rwid.dao
   PUBLIC
   ${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_SOURCE_DIR}/../flon.bootdao/include)

set_target_properties(rwid.dao
   PROPERTIES
   RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/ricardian/rwid.dao.contracts.md.in ${CMAKE_CURRENT_BINARY_DIR}/ricardian/rwid.dao.contracts.md @ONLY )

target_compile_options( rwid.dao PUBLIC -R${CMAKE_CURRENT_SOURCE_DIR}/ricardian -R${CMAKE_CURRENT_BINARY_DIR}/ricardian )

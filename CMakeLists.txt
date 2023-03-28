  cmake_minimum_required(VERSION 3.15)
  cmake_policy(SET CMP0091 NEW)
  cmake_policy(SET CMP0042 NEW)

  project (nim_bipf)

  add_definitions(-DNAPI_VERSION=4)

  include_directories(${CMAKE_JS_INC})
  include_directories(/Users/gpicron/.choosenim/toolchains/nim-1.6.12/lib)

  file(GLOB SOURCE_FILES "dist/src/*.c")

  add_library(${PROJECT_NAME} SHARED ${SOURCE_FILES} ${CMAKE_JS_SRC})
  set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "" SUFFIX ".node" INTERPROCEDURAL_OPTIMIZATION TRUE)
  target_link_libraries(${PROJECT_NAME} ${CMAKE_JS_LIB})
  target_compile_options(
    ${PROJECT_NAME}
    PRIVATE
    -Ofast
    -flto
    -ffast-math
  )

  if(MSVC AND CMAKE_JS_NODELIB_DEF AND CMAKE_JS_NODELIB_TARGET)
    # Generate node.lib
    execute_process(COMMAND ${CMAKE_AR} /def:${CMAKE_JS_NODELIB_DEF} /out:${CMAKE_JS_NODELIB_TARGET} ${CMAKE_STATIC_LINKER_FLAGS})
  endif()
  
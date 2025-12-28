# DistTarget.cmake
#
# Defines custom targets related to distributing source code.
# It requires to have populated 'PROJECT_NAME' and 'PROJECT_VERSION' variables,
# possibly through the project() command. It also uses 'PROJECT_DISTCONFIGURE_PARAMS'
# variable when configuring the unpacked distribution.
#
# Added targets:
# dist - only creates a tarball
# distcheck - creates a tarball and 'make && make install' it to a temporary prefix
#    to verify that the code can be built and installed; it also verifies
#    that the first line of the NEWS file contains the same version as
#    the tarball and that it claims today's date.

# Filenames for tarball
set(ARCHIVE_BASE_NAME ${PROJECT_NAME}-${PROJECT_VERSION})
set(ARCHIVE_FULL_NAME ${ARCHIVE_BASE_NAME}.tar.xz)

add_custom_target(
    dist
    COMMAND ${CMAKE_COMMAND} -E echo "Creating '${ARCHIVE_FULL_NAME}'..."
    COMMAND git archive --prefix=${ARCHIVE_BASE_NAME}/ HEAD | xz -z >
            ${CMAKE_CURRENT_BINARY_DIR}/${ARCHIVE_FULL_NAME}
    COMMAND ${CMAKE_COMMAND} -E echo
            "Distribution tarball '${ARCHIVE_FULL_NAME}' created at ${CMAKE_CURRENT_BINARY_DIR}"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

set(disttest_extract_dir "${CMAKE_CURRENT_BINARY_DIR}/${ARCHIVE_BASE_NAME}")
set(disttest_build_dir "${disttest_extract_dir}/_build")
set(disttest_install_dir "${disttest_extract_dir}/_install")

add_custom_command(
    OUTPUT ${disttest_build_dir}/Makefile
    # remove any left-over directory
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${disttest_extract_dir}
    # extract the tarball
    COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_CURRENT_BINARY_DIR} tar -xf ${ARCHIVE_FULL_NAME}
    # create a _build sub-directory
    COMMAND ${CMAKE_COMMAND} -E make_directory "${disttest_build_dir}"
    # configure the project with PROJECT_DISTCHECK_PARAMS
    COMMAND
        ${CMAKE_COMMAND} -E chdir "${disttest_build_dir}" ${CMAKE_COMMAND} -G "Unix Makefiles"
        ${PROJECT_DISTCONFIGURE_PARAMS} -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_INSTALL_PREFIX="${disttest_install_dir}" ..
    # 'make' the project
    COMMAND ${CMAKE_COMMAND} -E chdir ${disttest_build_dir} make -j
    DEPENDS dist
    COMMENT "Building from distribution tarball ${ARCHIVE_FULL_NAME}..."
)

add_custom_target(
    distcheck
    # 'make install' the project
    COMMAND ${CMAKE_COMMAND} -E chdir ${disttest_build_dir} make -j install
    # if we get this far, then everything worked, thus clean up
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${disttest_extract_dir}
    # and show the good news
    COMMAND ${CMAKE_COMMAND} -E echo "distcheck of '${ARCHIVE_FULL_NAME}' succeeded"
    DEPENDS ${disttest_build_dir}/Makefile
)

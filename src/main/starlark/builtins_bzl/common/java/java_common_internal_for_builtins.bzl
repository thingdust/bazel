# Copyright 2023 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

""" Private utilities for Java compilation support in Starlark. """

_java_common_internal = _builtins.internal.java_common_internal_do_not_use

def compile(
        ctx,
        output,
        java_toolchain,
        source_jars = [],
        source_files = [],
        output_source_jar = None,
        javac_opts = [],
        deps = [],
        runtime_deps = [],
        exports = [],
        plugins = [],
        exported_plugins = [],
        native_libraries = [],
        annotation_processor_additional_inputs = [],
        annotation_processor_additional_outputs = [],
        strict_deps = "ERROR",
        bootclasspath = None,
        sourcepath = [],
        resources = [],
        add_exports = [],
        add_opens = [],
        neverlink = False,
        enable_annotation_processing = True,
        # private to @_builtins:
        enable_compile_jar_action = True,
        enable_jspecify = True,
        include_compilation_info = True,
        classpath_resources = [],
        resource_jars = [],
        injecting_rule_kind = None):
    """Compiles Java source files/jars from the implementation of a Starlark rule

    The result is a provider that represents the results of the compilation and can be added to the
    set of providers emitted by this rule.

    Args:
        ctx: (RuleContext) The rule context
        output: (File) The output of compilation
        java_toolchain: (JavaToolchainInfo) Toolchain to be used for this compilation. Mandatory.
        source_jars: ([File]) A list of the jars to be compiled. At least one of source_jars or
            source_files should be specified.
        source_files: ([File]) A list of the Java source files to be compiled. At least one of
            source_jars or source_files should be specified.
        output_source_jar: (File) The output source jar. Optional. Defaults to
            `{output_jar}-src.jar` if unset.
        javac_opts: ([str]) A list of the desired javac options. Optional.
        deps: ([JavaInfo]) A list of dependencies. Optional.
        runtime_deps: ([JavaInfo]) A list of runtime dependencies. Optional.
        exports: ([JavaInfo]) A list of exports. Optional.
        plugins: ([JavaPluginInfo|JavaInfo]) A list of plugins. Optional.
        exported_plugins: ([JavaPluginInfo|JavaInfo]) A list of exported plugins. Optional.
        native_libraries: ([CcInfo]) CC library dependencies that are needed for this library.
        annotation_processor_additional_inputs: ([File]) A list of inputs that the Java compilation
            action will take in addition to the Java sources for annotation processing.
        annotation_processor_additional_outputs: ([File]) A list of outputs that the Java
            compilation action will output in addition to the class jar from annotation processing.
        strict_deps: (str) A string that specifies how to handle strict deps. Possible values:
            'OFF', 'ERROR', 'WARN' and 'DEFAULT'.
        bootclasspath: (BootClassPathInfo) If present, overrides the bootclasspath associated with
            the provided java_toolchain. Optional.
        sourcepath: ([File])
        resources: ([File])
        resource_jars: ([File])
        classpath_resources: ([File])
        neverlink: (bool)
        enable_annotation_processing: (bool) Disables annotation processing in this compilation,
            causing any annotation processors provided in plugins or in exported_plugins of deps to
            be ignored.
        enable_compile_jar_action: (bool) Enables header compilation or ijar creation. If set to
            False, it forces use of the full class jar in the compilation classpaths of any
            dependants. Doing so is intended for use by non-library targets such as binaries that
            do not have dependants.
        enable_jspecify: (bool)
        include_compilation_info: (bool)
        injecting_rule_kind: (str|None)
        add_exports: ([str]) Allow this library to access the given <module>/<package>. Optional.
        add_opens: ([str]) Allow this library to reflectively access the given <module>/<package>.
             Optional.

    Returns:
        (JavaInfo)
    """
    return _java_common_internal.compile(
        ctx,
        output = output,
        java_toolchain = java_toolchain,
        source_jars = source_jars,
        source_files = source_files,
        output_source_jar = output_source_jar,
        javac_opts = javac_opts,
        deps = deps,
        runtime_deps = runtime_deps,
        exports = exports,
        plugins = plugins,
        exported_plugins = exported_plugins,
        native_libraries = native_libraries,
        annotation_processor_additional_inputs = annotation_processor_additional_inputs,
        annotation_processor_additional_outputs = annotation_processor_additional_outputs,
        strict_deps = strict_deps,
        bootclasspath = bootclasspath,
        sourcepath = sourcepath,
        resources = resources,
        neverlink = neverlink,
        enable_annotation_processing = enable_annotation_processing,
        add_exports = add_exports,
        add_opens = add_opens,
        enable_compile_jar_action = enable_compile_jar_action,
        enable_jspecify = enable_jspecify,
        include_compilation_info = include_compilation_info,
        classpath_resources = classpath_resources,
        resource_jars = resource_jars,
        injecting_rule_kind = injecting_rule_kind,
    )

def run_ijar(
        actions,
        jar,
        java_toolchain,
        target_label = None,
        # private to @_builtins:
        output = None):
    """Runs ijar on a jar, stripping it of its method bodies.

    This helps reduce rebuilding of dependent jars during any recompiles consisting only of simple
    changes to method implementations. The return value is typically passed to JavaInfo.compile_jar

    Args:
        actions: (actions) ctx.actions
        jar: (File) The jar to run ijar on.
        java_toolchain: (JavaToolchainInfo) The toolchain to used to find the ijar tool.
        target_label: (Label|None) A target label to stamp the jar with. Used for `add_dep` support.
            Typically, you would pass `ctx.label` to stamp the jar with the current rule's label.
        output: (File) Optional.

    Returns:
        (File) The output artifact
    """
    return _java_common_internal.run_ijar(
        actions = actions,
        jar = jar,
        java_toolchain = java_toolchain,
        target_label = target_label,
        output = output,
    )

def merge(
        providers,
        # private to @_builtins:
        merge_java_outputs = True,
        merge_source_jars = True):
    """Merges the given providers into a single JavaInfo.

    Args:
        providers: ([JavaInfo]) The list of providers to merge.
        merge_java_outputs: (bool)
        merge_source_jars: (bool)

    Returns:
        (JavaInfo) The merged JavaInfo
    """
    return _java_common_internal.merge(
        providers,
        merge_java_outputs = merge_java_outputs,
        merge_source_jars = merge_source_jars,
    )

def target_kind(target, dereference_aliases = False):
    """Get the rule class string for a target

    Args:
        target: (Target)
        dereference_aliases: (bool) resolve the actual target rule class if an
            alias

    Returns:
        (str) The rule class string of the target
    """
    return _java_common_internal.target_kind(
        target,
        dereference_aliases = dereference_aliases,
    )

def to_java_binary_info(java_info):
    """Get a copy of the given JavaInfo with minimal info returned by a java_binary

    Args:
        java_info: (JavaInfo) A JavaInfo provider instance

    Returns:
        (JavaInfo) A JavaInfo instance representing a java_binary target
    """
    return _java_common_internal.to_java_binary_info(java_info)

def get_build_info(ctx, is_stamping_enabled):
    """Get the artifacts representing the workspace status for this build

    Args:
        ctx: (RuleContext) The rule context
        is_stamping_enabled: (bool) If stamping is enabled

    Returns
        ([File]) The build info artifacts
    """
    return _java_common_internal.get_build_info(ctx, is_stamping_enabled)

def collect_native_deps_dirs(deps):
    """Collect the set of root-relative paths containing native libraries

    Args:
        deps: [Target] list of targets

    Returns:
        ([String]) A set of root-relative paths as a list
    """
    return _java_common_internal.collect_native_deps_dirs(deps)

def get_runtime_classpath_for_archive(jars, excluded_jars):
    """Filters a classpath to remove certain entries

    Args
        jars: (depset[File]) The classpath to filter
        excluded_jars: (depset[File]) The files to remove

    Returns:
        (depset[File]) The filtered classpath
    """
    return _java_common_internal.get_runtime_classpath_for_archive(
        jars,
        excluded_jars,
    )

def filter_protos_for_generated_extension_registry(runtime_jars, deploy_env):
    """Get proto artifacts from runtime_jars excluding those in deploy_env

    Args:
        runtime_jars: (depset[File]) the artifacts to scan
        deploy_env: (depset[File]) the artifacts to exclude

    Returns
        (depset[File], bool) A tuple of the filtered protos and whether all protos are 'lite'
            flavored
    """
    return _java_common_internal.filter_protos_for_generated_extension_registry(
        runtime_jars,
        deploy_env,
    )

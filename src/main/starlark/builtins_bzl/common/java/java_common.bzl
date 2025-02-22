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

""" Utilities for Java compilation support in Starlark. """

load(":common/java/java_info.bzl", "JavaInfo")
load(":common/java/java_common_internal_for_builtins.bzl", "compile", "merge", "run_ijar")
load(":common/java/java_plugin_info.bzl", "JavaPluginInfo")
load(":common/java/java_semantics.bzl", "semantics")

_java_common_internal = _builtins.internal.java_common_internal_do_not_use

def _compile(
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
        neverlink = False,
        enable_annotation_processing = True,
        add_exports = [],
        add_opens = []):
    return compile(
        ctx,
        output,
        java_toolchain,
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
    )

def _run_ijar(actions, jar, java_toolchain, target_label = None):
    return run_ijar(
        actions = actions,
        jar = jar,
        java_toolchain = java_toolchain,
        target_label = target_label,
    )

def _stamp_jar(actions, jar, java_toolchain, target_label):
    """Stamps a jar with a target label for <code>add_dep</code> support.

    The return value is typically passed to `JavaInfo.compile_jar`. Prefer to use `run_ijar` when
    possible.

    Args:
        actions: (actions) ctx.actions
        jar: (File) The jar to run stamp_jar on.
        java_toolchain: (JavaToolchainInfo) The toolchain to used to find the stamp_jar tool.
        target_label: (Label) A target label to stamp the jar with. Used for `add_dep` support.
            Typically, you would pass `ctx.label` to stamp the jar with the current rule's label.

    Returns:
        (File) The output artifact

    """
    return _java_common_internal.stamp_jar(
        actions = actions,
        jar = jar,
        java_toolchain = java_toolchain,
        target_label = target_label,
    )

def _pack_sources(
        actions,
        java_toolchain,
        output_source_jar = None,
        sources = [],
        source_jars = []):
    """Packs sources and source jars into a single source jar file.

    The return value is typically passed to `JavaInfo.source_jar`. At least one of parameters
    output_jar or output_source_jar is required.

    Args:
        actions: (actions) ctx.actions
        java_toolchain: (JavaToolchainInfo) The toolchain used to find the ijar tool.
        output_source_jar: (File) The output source jar.
        sources: ([File]) A list of Java source files to be packed into the source jar.
        source_jars: ([File]) A list of source jars to be packed into the source jar.

    Returns:
        (File) The output artifact
    """
    return _java_common_internal.pack_sources(
        actions = actions,
        java_toolchain = java_toolchain,
        sources = sources,
        source_jars = source_jars,
        output_source_jar = output_source_jar,
    )

def _default_javac_opts(java_toolchain):
    """Experimental! Get default javacopts from a java toolchain

    Args:
        java_toolchain: (JavaToolchainInfo) the toolchain from which to get the javac options.

    Returns:
        ([str]) A list of javac options
    """
    return _java_common_internal.default_javac_opts(java_toolchain = java_toolchain)

def _merge(providers):
    return merge(providers)

def _make_non_strict(java_info):
    """Returns a new JavaInfo instance whose direct-jars part is the union of both the direct and indirect jars of the given Java provider.

    Args:
        java_info: (JavaInfo) The java info to make non-strict.

    Returns:
        (JavaInfo)
    """
    return _java_common_internal.make_non_strict(java_info)

def _get_message_bundle_info():
    return None if semantics.IS_BAZEL else _java_common_internal.MessageBundleInfo

def _add_constraints(java_info, constraints = []):
    """Returns a copy of the given JavaInfo with the given constraints added.

    Args:
        java_info: (JavaInfo) The JavaInfo to enhance
        constraints: ([str]) Constraints to add

    Returns:
        (JavaInfo)
    """
    return _java_common_internal.add_constraints(java_info, constraints = constraints)

def _get_constraints(java_info):
    """Returns a set of constraints added.

    Args:
        java_info: (JavaInfo) The JavaInfo to get constraints from.

    Returns:
        ([str]) The constraints set on the supplied JavaInfo
    """
    return _java_common_internal.get_constraints(java_info)

def _set_annotation_processing(
        java_info,
        enabled = False,
        processor_classnames = [],
        processor_classpath = None,
        class_jar = None,
        source_jar = None):
    """Returns a copy of the given JavaInfo with the given annotation_processing info.

    Args:
        java_info: (JavaInfo) The JavaInfo to enhance.
        enabled: (bool) Whether the rule uses annotation processing.
        processor_classnames: ([str]) Class names of annotation processors applied.
        processor_classpath: (depset[File]) Class names of annotation processors applied.
        class_jar: (File) Optional. Jar that is the result of annotation processing.
        source_jar: (File) Optional. Source archive resulting from annotation processing.

    Returns:
        (JavaInfo)
    """
    return _java_common_internal.set_annotation_processing(
        java_info,
        enabled = enabled,
        processor_classnames = processor_classnames,
        processor_classpath = processor_classpath,
        class_jar = class_jar,
        source_jar = source_jar,
    )

def _java_toolchain_label(java_toolchain):
    """Returns the toolchain's label.

    Args:
        java_toolchain: (JavaToolchainInfo) The toolchain.
    Returns:
        (Label)
    """
    return _java_common_internal.java_toolchain_label(java_toolchain)

def _make_java_common():
    methods = {
        "provider": JavaInfo,
        "compile": _compile,
        "run_ijar": _run_ijar,
        "stamp_jar": _stamp_jar,
        "pack_sources": _pack_sources,
        "default_javac_opts": _default_javac_opts,
        "merge": _merge,
        "make_non_strict": _make_non_strict,
        "JavaPluginInfo": JavaPluginInfo,
        "JavaToolchainInfo": _java_common_internal.JavaToolchainInfo,
        "JavaRuntimeInfo": _java_common_internal.JavaRuntimeInfo,
        "BootClassPathInfo": _java_common_internal.BootClassPathInfo,
        "experimental_java_proto_library_default_has_services": _java_common_internal.experimental_java_proto_library_default_has_services,
    }
    if _java_common_internal._google_legacy_api_enabled():
        methods.update(
            MessageBundleInfo = _get_message_bundle_info(),  # struct field that is None in bazel
            add_constraints = _add_constraints,
            get_constraints = _get_constraints,
            set_annotation_processing = _set_annotation_processing,
            java_toolchain_label = _java_toolchain_label,
        )
    return struct(**methods)

java_common = _make_java_common()

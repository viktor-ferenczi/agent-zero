from python.helpers import settings, projects


def get_context_workdir(context) -> str:
    """Return the effective workdir path for the given context.
    Priority: project folder > per-conversation subdir > global workdir_path.
    """
    # project folder takes priority
    project_name = projects.get_context_project_name(context)
    if project_name:
        return projects.get_project_folder(project_name)

    set = settings.get_settings()
    base = set["workdir_path"]

    # per-conversation isolation: append context_id as subdirectory
    if set.get("workdir_per_conversation", True) and context and getattr(context, "id", None):
        return base.rstrip("/") + "/" + context.id

    return base

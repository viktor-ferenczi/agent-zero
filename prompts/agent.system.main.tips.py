from python.helpers.files import VariablesPlugin
from python.helpers import settings
from python.helpers.workdir import get_context_workdir
from typing import Any

class WorkdirPath(VariablesPlugin):
    def get_variables(
        self, file: str, backup_dirs: list[str] | None = None, **kwargs
    ) -> dict[str, Any]:
        agent = kwargs.get("_agent")
        if agent and getattr(agent, "context", None):
            return {"workdir_path": get_context_workdir(agent.context)}

        set = settings.get_settings()
        return {"workdir_path": set["workdir_path"]}
        

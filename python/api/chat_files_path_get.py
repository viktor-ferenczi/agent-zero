from python.helpers.api import ApiHandler, Request, Response
from python.helpers import files
from python.helpers.workdir import get_context_workdir


class GetChatFilesPath(ApiHandler):
    async def process(self, input: dict, request: Request) -> dict | Response:
        ctxid = input.get("ctxid", "")
        if not ctxid:
            raise Exception("No context id provided")
        context = self.use_context(ctxid)

        folder = get_context_workdir(context)
        folder = files.normalize_a0_path(folder)

        return {
            "ok": True,
            "path": folder,
        }
from crewai.tasks import TaskOutput

from offensive_solidity_agents.tools.file import write_file


def write_output(output: TaskOutput):
    write_file(filename="output", extension=".js", content=output.raw)

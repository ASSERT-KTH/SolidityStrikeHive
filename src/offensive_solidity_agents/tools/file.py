from uuid import uuid4


def write_file(filename=str(uuid4()), extension=".sol", content=""):
    with open(f"{filename}.{extension}", "w") as f:
        f.write(content)

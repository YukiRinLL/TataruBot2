# FROM python:3.9 as requirements-stage

# WORKDIR /tmp

# COPY ./pyproject.toml ./poetry.lock* /tmp/

# RUN curl -sSL https://install.python-poetry.org -o install-poetry.py

# RUN python install-poetry.py --yes

# ENV PATH="${PATH}:/root/.local/bin"

# RUN poetry export -f requirements.txt --output requirements.txt --without-hashes

# FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9

# WORKDIR /app

# COPY --from=requirements-stage /tmp/requirements.txt /app/requirements.txt

# RUN pip install --no-cache-dir --upgrade -r requirements.txt

# RUN rm requirements.txt

# COPY ./ /app/


FROM python:3.9 as requirements-stage

WORKDIR /tmp

# 复制现有的 requirements.txt 文件
COPY ./requirements.txt /tmp/requirements.txt

FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9

WORKDIR /app

# 复制 requirements.txt 文件到目标目录
COPY --from=requirements-stage /tmp/requirements.txt /app/requirements.txt

# 安装依赖项
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# 安装 nonebot-adapter-onebot
RUN pip install nonebot-adapter-onebot

# 删除 requirements.txt 文件（可选）
RUN rm requirements.txt

# 复制项目文件到目标目录
COPY ./ /app/

# 复制配置文件到目标目录
COPY ./config.env /app/config.env

# 暴露 OneBot 的端口
EXPOSE 8080

# 启动命令
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080", "--log-level", "info"]

FROM ghcr.io/puppeteer/puppeteer:21.1.1 as base
# 21.9.0 不行

WORKDIR /app

USER root

ARG SCOPE # 用于定义构建参数，这些参数在构建镜像时可以被传递，但在容器运行时不可用
ENV SCOPE=$SCOPE # 用于设置环境变量，这些变量在容器运行时可用

ARG PACKAGE_CONTAINERS="apps packages"
ARG CLEANING_TARGETS="src test .turbo .eslintrc.* jest.config.* tsup.config.* tsconfig.*"

ARG PORT=3000
ENV PORT=$PORT
ENV MQTT_SEVER=emqx

RUN corepack enable # 实验性工具，管理包管理器的管理器
RUN npm install -g turbo

FROM base as pruner
COPY pnpm-lock.yaml . # 选择单独使用 COPY 命令来明确指定需要复制的文件，这样可以更清晰地表达意图。这种做法也有助于提高 Dockerfile 的可读性和可维护性
RUN pnpm fetch # 用于从远程仓库中获取包的信息和元数据，但不会安装这些包
ADD . . #将当前目录下的所有文件复制到容器中，可以理解为拷贝源码文件
RUN turbo prune --scope=$SCOPE --docker # 使用 Turbo 工具在容器中进行包裁剪，只保留指定 SCOPE 的包。 限制pnpm的子包

FROM base as installer
COPY --from=pruner /app/out/full . # 从之前的 pruner 阶段复制文件到当前阶段。
COPY --from=pruner /app/out/pnpm-lock.yaml .
RUN pnpm install -r

FROM base as builder
COPY --from=installer /app .
COPY --from=pruner /app/out/pnpm-workspace.yaml .
RUN pnpm run build --filter=$SCOPE

FROM base as runner
COPY --from=builder /app .
RUN pnpm install -r --prod --ignore-scripts
RUN for c in $PACKAGE_CONTAINERS; do \
    for t in $CLEANING_TARGETS; do \
    rm -rf ./$c/*/$t; \
    done; \
    done;
EXPOSE $PORT

RUN chown -R pptruser:pptruser /app
USER pptruser

CMD pnpm --filter=$SCOPE run start

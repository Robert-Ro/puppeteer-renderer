## Misc

### FAQ1

在这个 Dockerfile 中，使用多个 `FROM` 指令并为每个指令指定一个不同的命名，比如 `as pruner`、`as installer`、`as builder` 和 `as runner`，是为了创建多个阶段的镜像。

Docker 多阶段构建的主要目的是为了减小最终镜像的大小。在每个阶段，可以执行特定的操作，比如安装依赖、构建应用程序等，然后将需要的文件复制到下一个阶段。最终，只有最后一个阶段的镜像会被保留下来，而之前的阶段产生的镜像则会被丢弃，这样可以确保最终的镜像只包含必要的文件和依赖，而不包含构建过程中产生的临时文件和依赖。

在这个 Dockerfile 中，`as pruner` 阶段用于裁剪包，`as installer` 阶段用于安装依赖，`as builder` 阶段用于构建应用程序，而 `as runner` 阶段则用于设置容器的运行环境。通过使用多个阶段，可以更好地控制镜像的大小和内容，以及构建过程中的每个步骤。

### FAQ2

pnpm --filter: 过滤允许您将命令限制于包的特定子集。

> // FIXME 改造已有的项目

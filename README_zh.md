学生姓名：WU Dihang     

学号：26040407g

本实验的 Github 地址：https://github.com/DihangWU/EIE575_Lab.git

本实验参考了教程 PDF，但在课堂上完成实验后，将环境从 Windows 替换为 Linux，并做了少量修改。

## 开发环境

| 工具 | 版本 | 本地路径 |
|---|---|---|
| sumo | 1.22.0 | `/home/maple/sumo-1.22.0/bin/sumo` |
| sumo-gui | 1.22.0 | `/home/maple/sumo-1.22.0/bin/sumo-gui` |
| netconvert | 1.22.0 | `/home/maple/sumo-1.22.0/bin/netconvert` |
| omnetpp | 6.1 | `/home/maple/omnetpp-6.1/bin/omnetpp` |
| veins_launchd | 5.3.1  | `/home/maple/veins-5.3.1/bin/veins_launchd` |
| veins_run | 5.3.1  | `/home/maple/veins-5.3.1/bin/veins_run` |
| make(GNU) | 4.3 | `/usr/bin/make` |
| clang | 18.1.3 | `/usr/bin/clang` |
| python3 | 3.12.3 | `/usr/bin/python3` |

![替代文本](report/images/image1_dev_env.png)

## Lab1
Lab1 模拟了一个 SUMO 道路交通场景，包括：
* 道路网络：两个节点之间的一条双向道路，每个方向有两条机动车道，并设有人行道和人行横道。
* 公交站：两个公交站，公交车在每站停留 20 秒。
* 车辆生成：5 辆公交车和 25 辆小汽车，小汽车以 10 秒的间隔分批进入道路。
* 路线配置：车辆沿预定义的路线行驶，并表现出加速、减速、公交站停车和跟车等交通行为。
* 道路网络使用 netconvert 生成，仿真在 SUMO 中运行 300 秒的仿真时间。可以通过 sumo-gui 观察车辆运动。

### 工程文件

| 工程文件 | 功能 |
|---|---|
| `lab1.nod.xml` | 定义道路节点及其坐标。 |
| `lab1.edg.xml` | 定义道路、车道数量、限速、人行道和环岛声明。 |
| `lab1.conn.xml` | 定义人行横道及其优先权。 |
| `lab1.net.xml` | 存储由 `netconvert` 自动生成的完整道路网络。 |
| `lab1.add.xml` | 定义公交站及其在车道上的位置。 |
| `lab1.rou.xml` | 定义车辆类型、路线、出发计划、交通流和停车时长。 |
| `lab1.sumo.cfg` | 指定仿真输入文件、开始和结束时间以及日志设置。 |
| `lab1.sumo_gui_settings.xml` | 为 SUMO GUI 选择 `real world` 可视化方案。 |

#### `lab1.nod.xml`
* 这是一个描述（道路的）2 个节点的配置文件
    ```xml
    <nodes>
        <node id="1" x="-150.0" y="0.0" />
        <node id="2" x="+50.0" y="0.0" />
    </nodes>
    ```
    * `id` `1` 和 `2`：分别为 2 个节点的名称
    *  `x`,`y`：2 个节点的坐标

#### `lab1.edg.xml`
* 此配置文件描述连接节点的道路。
    ```xml
    <edges>
        <edge from="1" id="1to2" to="2" numLanes="2" speed="16.667" sidewalkWidth="1"/>
        <edge from="2" id="2to1" to="1" numLanes="2" speed="16.667" sidewalkWidth="1"/>

        <roundabout edges="1to2 2to1"/>
        <roundabout edges="2to1 1to2"/>
    </edges>
    ```
    * `"1to2"` 和 `"2to1"`：分别命名 2 个方向的 2 条道路
    * `numLanes="2"`：每条道路有 2 条车道
    * `speed="16.667"`：这 2 条道路的限速均为 16.667 m/s
    * `sidewalkWidth="1"`：添加宽度为 2m 的人行道
    * `<roundabout edges="1to2 2to1"/>`：将 `"edges"` 定义为环岛
        * 两个环岛定义是重复的；可以删除其中一个。

#### `lab1.conn.xml`
* 此配置文件描述横跨道路的人行横道
    ```xml
        <connections>
            <crossing node="2" edges="1to2 2to1" priority="true" width="1"/>
        </connections>
    ```
    * `node="2"`：节点处有一条人行横道，它连接 2 个方向的 2 条道路
    * `edges="1to2 2to1"`：横跨这 2 条道路
    * `priority="true"`：给予行人优先权
    * `width="1"` = 1m




#### `lab1.net.xml`
* 这是由 `netconvert` 根据 `lab1.nod.xml`、`lab1.edg.xml` 和 `lab1.conn.xml` 生成的完整道路网络文件，包含这 3 个配置文件的信息，可由 SUMO 直接加载。
    ```shell
    cd Lab1
    netconvert --node-files=lab1.nod.xml --edge-files=lab1.edg.xml --connection-files=lab1.conn.xml --output-file=lab1.net.xml
    ```
    * `--node-files`：读取节点的位置。
    * `--edge-files`：读取节点之间的道路。
    * `--connection-files`：读取人行横道配置。
    * `--output-file`：指定生成的路网文件。

#### `lab1.add.xml`
* 此配置文件描述两个公交站的位置。
    ```xml
    <additional>
        <busStop id="1" lane="1to2_1" startPos="33.57" endPos="53.57" lines="1_1"/>
        <busStop id="2" lane="2to1_1" startPos="39.58" endPos="59.58" lines="1_2"/>
    </additional>
    ```
    * `id`：每个公交站的名称。
    * `lane`：公交站所在的车道。两个站点分别位于道路的相反方向。
    * `startPos` 和 `endPos`：站点区域的起点和终点，从车道起点沿车道以米为单位测量。
        * 站点 1 从 33.57m 延伸到 53.57m，站点 2 从 39.58m 延伸到 59.58m。两个站点区域均长 20m。
    * `lines`：为站点显示的公交线路标签。
    * 此文件定义站点的位置。停车时长单独在 `lab1.rou.xml` 中定义。

#### `lab1.rou.xml`
* 此配置文件定义车辆类型、路线、各辆公交车和小汽车流。
* 第一部分定义两种车辆类型。
    ```xml
    <vType id="1" accel="2.6" decel="4.5" sigma="0" length="10" minGap="3" maxSpeed="60" color="1,1,0" guiShape="bus"/>
    <vType id="2" accel="1.0" decel="5.0" sigma="0.0" length="2.0" maxSpeed="100.0" color="1,0,0" />
    ```
    * `id="1"` 用于公交车，`id="2"` 用于小汽车。
    * `accel`：加速度参数，单位为 m/s²。公交车为 2.6，小汽车为 1.0。
    * `decel`：正常减速度参数，单位为 m/s²。公交车为 4.5，小汽车为 5.0。
    * `sigma="0"`：将默认跟车模型的驾驶员不完美性参数设为零。其他默认参数仍可能导致车辆之间存在差异。
    * `length`：车辆长度，单位为米。公交车长 10m，小汽车长 2m。
    * `minGap="3"`：将公交车静止时的最小间距设为 3m。
    * `maxSpeed`：车辆自身的最大速度参数，单位为 m/s。数值 60 和 100 不是车辆必须保持的速度。实际运动还取决于道路限速、速度因子、其他车辆和停车。
    * `color="1,1,0"` 表示黄色，而 `color="1,0,0"` 表示红色。这三个值分别代表红、绿、蓝分量。
    * `guiShape="bus"`：使用公交车形状显示车辆。
* 下一部分定义公交车的共用路线。
    ```xml
    <route id="route0" edges="1to2 2to1">
        <stop busStop="1" duration="20"/>
        <stop busStop="2" duration="20"/>
    </route>
    ```
    * `id="route0"`：公交车引用此路线时使用的名称。
    * `edges="1to2 2to1"`：先从节点 1 行驶到节点 2，再从节点 2 返回节点 1。
    * `busStop="1"` 和 `busStop="2"` 引用 `lab1.add.xml` 中定义的站点。
    * `duration="20"`：在每个公交站停留 20 秒的仿真时间。
    * 车辆完成路线后离开仿真。环岛声明不会使路线无限重复。
* 五辆公交车由从 `Lab1/lab1.rou.xml` 中提取的以下 `vehicle` 元素定义：

    ```xml
    <vehicle id="KMB_1" color="1,1,0" route="route0" depart="0" type="1"/>
    <vehicle id="KMB_2" color="1,1,0" route="route0" depart="51" type="1"/>
    <vehicle id="KMB_3" color="1,1,0" route="route0" depart="101" type="1"/>
    <vehicle id="KMB_4" color="1,1,0" route="route0" depart="151" type="1"/>
    <vehicle id="KMB_5" color="1,1,0" route="route0" depart="201" type="1"/>
    ```

    * `id`：标识每辆公交车，从 `KMB_1` 到 `KMB_5`。
    * `route="route0"`：使用共用的公交路线及其停车指令。
    * `depart`：指定计划出发时间，以仿真秒为单位。
    * `type="1"`：使用车辆类型 1 的参数。
    * 读取 `depart` 值可得到以下公交车出发计划：

        | 车辆 ID | 计划出发时间（秒） |
        |---|---|
        | KMB_1 | 0 |
        | KMB_2 | 51 |
        | KMB_3 | 101 |
        | KMB_4 | 151 |
        | KMB_5 | 201 |

* 小汽车由从同一源文件中提取的以下五个 `flow` 元素生成：

    ```xml
    <flow id="car_route" color="1,0,0"  begin="0" end="50" period="10" type="2">
        <route edges="1to2 2to1"/>
    </flow>
    <flow id="car_route1" color="1,0,0" begin="52" end= "100" period="10" type="2">
        <route edges="1to2 2to1"/>
    </flow>
    <flow id="car_route2" color="1,0,0" begin="102" end="150" period="10" type="2">
        <route edges="1to2 2to1"/>
    </flow>
    <flow id="car_route3" color="1,0,0" begin="152" end="200" period="10" type="2">
        <route edges="1to2 2to1"/>
    </flow>
    <flow id="car_route4" color="1,0,0" begin="202" end="250" period="10" type="2">
        <route edges="1to2 2to1"/>
    </flow>
    ```

    * `begin`：每个交通流中第一辆小汽车的计划出发时间。
    * `end`：出发时间区间的终点；不包含该时刻。
    * `period="10"`：在该区间内每 10 秒安排一辆小汽车。
    * `type="2"`：使用小汽车类型。
    * 每个交通流都包含自己的 `<route edges="1to2 2to1"/>`。小汽车沿道路的两个方向行驶，不包含公交车的停车指令。
    * 例如，`car_route` 的设置为 `begin="0"`、`end="50"` 和 `period="10"`，因此其计划出发时间为 0、10、20、30 和 40 秒。
    * 将同一规则应用于全部五个交通流，可得到：

        | 交通流 ID | 计划出发时间（秒） | 小汽车数量 |
        |---|---|---|
        | car_route | 0, 10, 20, 30, 40 | 5 |
        | car_route1 | 52, 62, 72, 82, 92 | 5 |
        | car_route2 | 102, 112, 122, 132, 142 | 5 |
        | car_route3 | 152, 162, 172, 182, 192 | 5 |
        | car_route4 | 202, 212, 222, 232, 242 | 5 |

* 五个 `vehicle` 元素创建 5 辆公交车。五个 `flow` 元素中的每一个安排 5 辆小汽车，共计 25 辆小汽车和 30 辆车。如果没有足够空间安全插入车辆，计划出发可能会延迟。

#### `lab1.sumo.cfg`
* 这是 SUMO 启动时加载的主配置文件。
    ```xml
    <configuration>
        <input>
            <net-file value="lab1.net.xml"/>
            <route-files value="lab1.rou.xml"/>
            <additional-files value="lab1.add.xml"/>
        </input>
        <time>
            <begin value="0"/>
            <end value="300"/>
        </time>
        <report>
            <no-step-log value="true"/>
        </report>
    </configuration>
    ```
    * `net-file`：加载生成的道路网络。
    * `route-files`：加载车辆类型、路线和出发计划。
    * `additional-files`：加载公交站。
    * 相对输入路径从包含此配置文件的目录解析，即 `Lab1/`。
    * `begin="0"` 和 `end="300"`：从仿真时间 0s 运行到 300s。这与现实世界中等待所花费的时间不同。
    * `no-step-log="true"`：抑制终端中常规的逐步进度消息。

#### `lab1.sumo_gui_settings.xml`
* 这是一个额外的显示配置
    ```xml
    <viewsettings>
        <scheme name="real world"/>
    </viewsettings>
    ```
    * `real world` 方案改变道路、车辆和背景的外观。
    * 它不会使仿真时间等于现实时间，也不会改变交通模型。
    * 此文件由 `Lab1/Makefile` 中的 `--gui-settings-file` 参数加载。

### 在 Linux 上运行 Lab1

从工程根目录运行。要在 SUMO GUI 中观察交通：

```shell
make -C Lab1 lab1-sumo-gui
```

点击 SUMO 运行按钮以开始。此命令会在需要时自动生成道路网络。要在没有图形窗口的情况下运行，改用 `make -C Lab1 lab1-sumo`。只想生成或更新路网时，使用 `make -C Lab1 lab1-netconvert`。

* Makefile 使用的 GUI 命令为：
    ```shell
    cd Lab1
    sumo-gui -c lab1.sumo.cfg --gui-settings-file lab1.sumo_gui_settings.xml --delay 100
    ```
    * `-c`：指定主仿真配置。
    * `--gui-settings-file`：指定显示配置。
    * `--delay 100`：在仿真步之间添加 100ms 的延迟，使车辆运动更容易观察。
* 执行顺序为：生成或复用路网，加载仿真配置及其输入，按照计划插入车辆，更新车辆运动和停车状态，并在配置的仿真结束时间结束。

### 仿真截图
![替代文本](report/images/image2_Lab1.png)

## Lab2

Lab2 使用 OMNeT++、Veins 和 Lab1 的 SUMO 道路交通场景模拟一个车载通信场景，包括：
* 网络配置：一个名为 `hello` 的网络，包含由 Veins 管理的车辆节点和一个路侧单元（RSU）。
* 交通同步：OMNeT++ 通过 TraCI 与 SUMO 通信，以更新车辆的位置和运动。
* 无线通信：车辆和 RSU 使用 IEEE 802.11p PHY 和 IEEE 1609.4 MAC 模型，并周期性发送基本安全消息（BSM）。
* 事故配置：指示选定的车辆临时停车，以模拟事故。
* 仿真配置：仿真最多运行 300 秒的仿真时间，并为信道切换提供单独的配置。

### 工程文件

以下文件位于 `Lab2/core/` 中。

| 工程文件 | 功能 |
|---|---|
| `package.ned` | 定义核心网络文件的 NED 包。 |
| `lab2.ned` | 定义网络，并向 Veins 场景添加一个 RSU。 |
| `omnetpp.ini` | 定义仿真、TraCI 连接、RSU、无线通信、应用、移动性和事故设置。 |
| `lab2.launchd.xml` | 指定启动交通仿真时使用的 SUMO 文件。 |
| `config.xml` | 定义无线电传播模型和接收判决模型。 |
| `support/` | 存放用于在Linux环境中编译、运行和分析 Lab2 的辅助代码与配置。 |

#### `package.ned`
* 此文件定义 core 目录中 NED 文件使用的包名。
    ```ned
    package org.car2x.veins;
    ```
    * `package`：声明 NED 定义的命名空间。
    * `org.car2x.veins`：此 Lab2 网络的包名。它也用于 `omnetpp.ini` 中的网络选择。

#### `lab2.ned`
* 此文件通过扩展现有的 Veins 场景来定义仿真网络。
    ```ned
    package org.car2x.veins;

    import org.car2x.veins.nodes.RSU;
    import org.car2x.veins.nodes.Scenario;

    network hello extends Scenario
    {
        submodules:
            rsu[1]: RSU
            {
                @display("p=150,140;i=veins/sign/yellowdiamond;is=vs;r=500");
            }
    }
    ```
    * `import`：使现有的 Veins `RSU` 和 `Scenario` 类型可供此文件使用。
    * `network hello extends Scenario`：将网络命名为 `hello`，并继承 Veins 的场景基础结构。其完整名称为 `org.car2x.veins.hello`。
    * `submodules`：声明此网络中包含的模块。
    * `rsu[1]: RSU`：创建一个包含一个 RSU 的数组，其索引为 `rsu[0]`。
    * `@display`：配置 RSU 在 OMNeT++ 网络视图中的显示方式。
        * `p=150,140`：设置 RSU 图标的图形布局位置。
        * `i=veins/sign/yellowdiamond` 和 `is=vs`：选择图标及其大小。
        * `r=500`：绘制一个半径为 500 个显示单位的指示区域。这并不定义实际的无线通信范围。
    * 实际 RSU 坐标单独在 `omnetpp.ini` 中定义。车辆进入 SUMO 仿真时，会动态创建车辆节点。

#### `omnetpp.ini`
* 这是 OMNeT++ 仿真的主配置文件。
* 第一部分选择网络并配置终端进度消息。
    ```ini
    [General]
    cmdenv-express-mode = true
    cmdenv-autoflush = true
    cmdenv-status-frequency = 1s
    **.cmdenv-log-level = info

    network = org.car2x.veins.hello
    ```
    * `[General]`：定义仿真配置使用的通用设置。
    * `cmdenv-express-mode = true`：在命令行仿真环境中使用快速模式，减少详细事件输出。
    * `cmdenv-autoflush = true`：自动刷新命令行输出。
    * `cmdenv-status-frequency = 1s`：将进度报告间隔设为大约一秒的实际经过时间。
    * `**.cmdenv-log-level = info`：对命令行环境中的模块使用 `info` 日志级别。
    * `network`：使用完整包名选择 `lab2.ned` 中声明的网络。
* 下一部分定义仿真时长、结果记录和仿真区域尺寸。
    ```ini
    debug-on-errors = false
    print-undisposed = false
    sim-time-limit = 300s

    **.scalar-recording = true
    **.vector-recording = true

    *.playgroundSizeX = 500m
    *.playgroundSizeY = 500m
    *.playgroundSizeZ = 50m
    *.annotations.draw = true
    ```
    * `debug-on-errors = false`：发生仿真错误时，不请求调试器中断。错误仍可能使仿真停止。
    * `print-undisposed = false`：禁用仿真结束时对未释放对象的报告。
    * `sim-time-limit = 300s`：将运行限制为 300 秒的仿真时间。
    * `scalar-recording`：启用单个数值结果的记录，例如消息数量和总距离。
    * `vector-recording`：启用时间序列结果的记录，例如不同仿真时刻的车辆速度。
    * `playgroundSizeX`、`playgroundSizeY` 和 `playgroundSizeZ`：将 OMNeT++ 仿真区域尺寸定义为 500m、500m 和 50m。这些设置不会生成 SUMO 路网或调整其大小。
    * `annotations.draw = true`：启用图形仿真视图中的标注绘制。
* TraCI 管理器设置定义 OMNeT++ 如何连接 SUMO 启动代理。
    ```ini
    *.manager.updateInterval = 1s
    *.manager.host = "localhost"
    *.manager.port = 9999
    *.manager.autoShutdown = true
    *.manager.launchConfig = xmldoc("lab2.launchd.xml")
    ```
    * `updateInterval = 1s`：以一秒的仿真间隔更新耦合的交通仿真。
    * `host = "localhost"`：连接同一台计算机上的代理。
    * `port = 9999`：使用 TCP 端口 9999 进行代理连接。
    * `autoShutdown = true`：当 SUMO 报告没有剩余交通需要仿真时，允许管理器结束仿真，即使尚未达到时间限制。
    * `launchConfig`：从与此 INI 文件同一目录下的 `lab2.launchd.xml` 加载 XML 启动指令。
* RSU 设置定义其物理位置和应用参数。
    ```ini
    *.rsu[0].mobility.x = 500
    *.rsu[0].mobility.y = 500
    *.rsu[0].mobility.z = 3

    *.rsu[*].applType = "TraCIDemoRSU11p"
    *.rsu[*].appl.headerLength = 80 bit
    *.rsu[*].appl.sendBeacons = true
    *.rsu[*].appl.dataOnSch = false
    *.rsu[*].appl.beaconInterval = 1s
    *.rsu[*].appl.beaconUserPriority = 7
    *.rsu[*].appl.dataUserPriority = 5
    ```
    * `rsu[0].mobility.x`、`y` 和 `z`：将 RSU 放置在仿真坐标 (500m, 500m, 3m) 处。
    * `rsu[*]`：将设置应用于所有 RSU。此网络中有一个 RSU。
    * `applType = "TraCIDemoRSU11p"`：使用 Veins 的 RSU 演示应用，它可以转发收到的交通更新消息。
    * `headerLength = 80 bit`：将应用头部长度设为 80 比特。
    * `sendBeacons = true`：启用周期性信标消息（BSM）。
    * `dataOnSch = false`：在控制信道（CCH）上发送应用数据，而不是服务信道（SCH）。
    * `beaconInterval = 1s`：将标称信标间隔设为一秒的仿真时间。
    * `beaconUserPriority = 7` 和 `dataUserPriority = 5`：分别为信标消息和数据消息分配 MAC 用户优先级。这些值会影响消息到接入类别的映射方式。
* 连接管理器设置控制模块之间如何传递无线传输。
    ```ini
    *.connectionManager.sendDirect = true
    *.connectionManager.maxInterfDist = 2600m
    *.connectionManager.drawMaxIntfDist = false
    ```
    * `sendDirect = true`：在相关仿真模块之间直接传递无线传输。
    * `maxInterfDist = 2600m`：设置连接管理器使用的最大干扰距离。这不保证数据包可以在该距离处被解码。
    * `drawMaxIntfDist = false`：不在图形视图中绘制最大干扰距离。
* IEEE 1609.4 MAC 设置定义信道使用、发射功率和比特率。
    ```ini
    *.**.nic.mac1609_4.useServiceChannel = false
    *.**.nic.mac1609_4.txPower = 20mW
    *.**.nic.mac1609_4.bitrate = 6Mbps
    ```
    * `useServiceChannel = false`：在默认配置中禁用控制信道与服务信道之间的切换。
    * `txPower = 20mW`：将无线电发射功率设为 20 毫瓦。
    * `bitrate = 6Mbps`：将传输比特率设为每秒 6 兆比特。
    * `*.**.nic` 模式将这些设置应用于车辆和 RSU 中匹配的网络接口。
* IEEE 802.11p PHY 设置定义接收灵敏度、背景噪声和无线电模型。
    ```ini
    *.**.nic.phy80211p.minPowerLevel = -89dBm
    *.**.nic.phy80211p.useNoiseFloor = true
    *.**.nic.phy80211p.noiseFloor = -110dBm
    *.**.nic.phy80211p.decider = xmldoc("config.xml")
    *.**.nic.phy80211p.analogueModels = xmldoc("config.xml")
    *.**.nic.phy80211p.usePropagationDelay = true
    ```
    * `minPowerLevel = -89dBm`：设置 PHY 接收模型使用的最小接收功率阈值。高于此阈值的信号不一定能成功解码，因为噪声和干扰也会产生影响。
    * `useNoiseFloor = true` 和 `noiseFloor = -110dBm`：包含一个 -110dBm 的背景噪声底。
    * `decider`：从 `config.xml` 读取接收判决模型。
    * `analogueModels`：从同一个 XML 文件读取信号传播模型。
    * `usePropagationDelay = true`：考虑无线电信号在节点之间传播所需的时间。
* 车辆应用设置启用 Veins 演示应用和周期性信标。
    ```ini
    *.node[*].applType = "TraCIDemo11p"
    *.node[*].appl.headerLength = 80 bit
    *.node[*].appl.sendBeacons = true
    *.node[*].appl.dataOnSch = false
    *.node[*].appl.beaconInterval = 1s
    ```
    * `node[*]`：将设置应用于管理器创建的所有车辆节点。
    * `applType = "TraCIDemo11p"`：使用 Veins 的车辆演示应用，它可以在车辆持续停止时生成和转发交通警告。
    * `headerLength = 80 bit`：将应用头部长度设为 80 比特。
    * `sendBeacons = true` 和 `beaconInterval = 1s`：启用标称间隔为一秒的 BSM。
    * `dataOnSch = false`：在默认配置中使用控制信道传输应用数据。
* 移动性设置选择车辆移动性模块并配置计划事故。
    ```ini
    *.node[*].veinsmobilityType = "Lab2TraCIMobility"
    *.node[*].veinsmobility.x = 0
    *.node[*].veinsmobility.y = 0
    *.node[*].veinsmobility.z = 1.895
    *.node[*0].veinsmobility.accidentCount = 1
    *.node[*0].veinsmobility.accidentStart = 75s
    *.node[*0].veinsmobility.accidentDuration = 50s
    ```
    * `veinsmobilityType = "Lab2TraCIMobility"`：选择本工程用于本地环境的 TraCI 移动性变体。
    * `x = 0` 和 `y = 0`：提供配置的移动性坐标；实际车辆位置由 SUMO 通过 TraCI 提供和更新。
    * `z = 1.895`：将车辆移动性高度设为 1.895m。
    * `node[*0]`：匹配以 `0` 结尾的车辆索引，例如 `node[0]`、`node[10]` 和 `node[20]`。
    * `accidentCount = 1`：为每辆匹配的车辆安排一次事故。
    * `accidentStart = 75s`：在该车辆的移动性模块初始化 75 秒后安排事故。它不一定是绝对仿真时间 75s。
    * `accidentDuration = 50s`：请求将速度设为零并持续 50 秒，然后解除速度覆盖，使 SUMO 能够再次控制车辆。这通过停车来表示事故；不要求两辆车在画面上发生碰撞。
    * 只有当相应车辆在该时刻仍存在于仿真中时，计划事故才可能发生。
* 最后一部分定义启用信道切换的另一种配置。
    ```ini
    [Config WithChannelSwitching]
    *.**.nic.mac1609_4.useServiceChannel = true
    *.node[*].appl.dataOnSch = true
    *.rsu[*].appl.dataOnSch = true
    ```
    * `[Config WithChannelSwitching]`：定义一个命名配置，继承 `[General]` 中的通用设置。
    * `useServiceChannel = true`：启用 MAC 在控制信道与服务信道之间的切换。
    * `dataOnSch = true`：在服务信道上发送车辆和 RSU 的应用数据。信标仍保留在控制信道上。
    * 其他仿真、交通和无线电设置仍继承自 `[General]`。

#### `lab2.launchd.xml`
* 此文件指定启动交通仿真时需要复制的 SUMO 输入。
    ```xml
    <launch>
        <basedir path="../../Lab1"/>
        <copy file="lab1.net.xml"/>
        <copy file="lab1.rou.xml"/>
        <copy file="lab1.add.xml"/>
        <copy file="lab1.sumo.cfg" type="config"/>
    </launch>
    ```
    * `<launch>`：包含传递给 SUMO 代理的启动指令。
    * `basedir`：指定代理查找源文件的位置。在本工程的启动设置中，`../../Lab1` 从代理的工作目录解析到现有的 Lab1 目录。
    * `<copy>`：将每个所需文件复制到用于一次 SUMO 运行的临时目录。
    * `lab1.net.xml`：提供生成的道路网络。
    * `lab1.rou.xml`：提供车辆类型、路线、出发计划和公交车停车指令。
    * `lab1.add.xml`：提供公交站定义。
    * `lab1.sumo.cfg` 和 `type="config"`：标识要加载的主 SUMO 配置文件。
    * Lab2 复用 Lab1 的交通输入，而不是在此文件中定义另一个道路网络。

#### `config.xml`
* 此文件定义 `omnetpp.ini` 引用的无线电传播和接收模型。
    ```xml
    <root>
        <AnalogueModels>
            <AnalogueModel type="SimplePathlossModel">
                <parameter name="alpha" type="double" value="2.0"/>
            </AnalogueModel>
        </AnalogueModels>
        <Decider type="Decider80211p">
            <!-- The center frequency on which the phy listens -->
            <parameter name="centerFrequency" type="double" value="5.890e9"/>
        </Decider>
    </root>
    ```
    * `<root>`：包含传播模型和接收判决模型配置。
    * `<AnalogueModels>`：列出应用于发射无线电信号的模型。
    * `type="SimplePathlossModel"`：使用基于距离的信号衰减模型。
    * `alpha`：路径损耗指数。当 `value="2.0"` 时，在其他条件保持不变的情况下，接收功率大致随距离的平方而减小。
    * `type="double"`：将参数值解释为浮点数。
    * `<Decider type="Decider80211p">`：选择考虑信号质量、评估 IEEE 802.11p 接收是否成功的模型。
    * `centerFrequency = 5.890e9`：将监听中心频率设为 58.90 亿赫兹，即 5.89GHz。

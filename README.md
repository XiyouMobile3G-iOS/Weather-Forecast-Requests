# iOS 天气预报项目要求

`Weather-Forecast/` 是功能范例，用于理解页面和业务流程，不代表推荐的代码结构，请勿直接照抄。

本项目技术栈固定为 **Objective-C + UIKit**；学习和实现时不要改用 Swift、SwiftUI 或跨平台框架。

参考视频：[old example.MP4](<./old example.MP4>)、[iOS 27 beta3.mov](<./iOS 27 beta3.mov>)。视频用于理解页面效果、交互方式和功能流程，不要求逐像素复刻，也不代表推荐的代码架构或第三方技术选型；实现与验收仍以本 README 的文字要求为准。

## 开始前：先学会原生网络请求

建议按顺序阅读：

1. [学姐的 Objective-C 网络请求与数据解析入门](https://blog.csdn.net/streamery/article/details/99622310)：先理解 `NSURL`、`NSURLRequest`、`NSURLSessionDataTask`、协议回调及 JSON 数据的基本流向。
2. [Apple：URL Loading System](https://developer.apple.com/documentation/foundation/url_loading_system)：核对 `NSURLSession` 的正式用法、任务生命周期和错误处理。
3. [Apple：NSJSONSerialization](https://developer.apple.com/documentation/foundation/nsjsonserialization)：学习使用系统 API 将 JSON 转成 Foundation 对象，再自行映射为 Model。
4. [天气 App 仿写文章](https://blog.csdn.net/weixin_72437555/article/details/132071040)：仅参考首页、实时搜索、添加与浏览等功能流程。

> 博客用于入门和理解需求，其中代码不等于本项目最终架构。阅读后仍须将请求移入自建网络单例，并按本 README 的 MVC、线程和业务规则完成项目。

<details>
<summary>可选的免费天气 REST API（需要时展开）</summary>

以下服务都能通过 `NSURLSession` 直接请求 JSON，不需要接入厂商 SDK。免费额度和条款可能调整，开始开发前应再次查看官网。

### 1. Open-Meteo（最推荐）

- [天气 API 文档](https://open-meteo.com/en/docs)｜[城市搜索 API 文档](https://open-meteo.com/en/docs/geocoding-api)｜[免费层说明](https://open-meteo.com/en/pricing)
- 非商业免费层无需注册和 API Key；官网当前标明每天最多 10,000 次调用，并要求遵守署名及公平使用规则。
- 城市搜索和天气查询分开进行，适合练习 Model、多个请求及城市唯一 ID；天气结果以经纬度查询。

```text
# 模糊搜索城市（先对输入文字进行 URL 编码）
https://geocoding-api.open-meteo.com/v1/search?name=Xi%27an&count=10&language=zh&format=json

# 根据西安经纬度查询当前、逐小时及每日天气
https://api.open-meteo.com/v1/forecast?latitude=34.3416&longitude=108.9398&current=temperature_2m,weather_code&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto
```

### 2. WeatherAPI（容易入门）

- [API 文档](https://www.weatherapi.com/docs/)｜[价格与免费额度](https://www.weatherapi.com/pricing.aspx)
- 需要注册免费的 API Key；官网当前免费方案为每月 100,000 次调用、最多 3 日预报。
- 自带城市搜索接口，返回结构直观；如果项目必须展示 7 日预报，当前免费方案不满足，应改用 Open-Meteo 或其他合规接口。

```text
https://api.weatherapi.com/v1/search.json?key=YOUR_API_KEY&q=Xi%27an
https://api.weatherapi.com/v1/forecast.json?key=YOUR_API_KEY&q=Xi%27an&days=3
```

`YOUR_API_KEY` 只能放入不提交的本地配置或运行环境中，示例值、真实 Key 均不得写进源码、记忆文档或 Git 历史。

### 3. MET Norway Locationforecast（无 Key 备选）

- [Locationforecast 文档](https://api.met.no/weatherapi/locationforecast/2.0/documentation)
- 使用经纬度返回 JSON，不需要 API Key，但必须按官方要求设置能够标识应用的 `User-Agent`，否则可能返回 `403`；还应遵守缓存和使用条款。

```text
https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=34.3416&lon=108.9398
```

### 4. 美国 NWS（仅适合美国地点）

- [NWS API 官方说明](https://www.weather.gov/documentation/services-web-api)
- 美国政府开放数据，不收费且当前不需要 Key，但需要 `User-Agent`，并有合理限流；覆盖重点是美国，不能用于本项目的全球城市需求时不要选择。
- 通常先请求 `https://api.weather.gov/points/{lat},{lon}`，再读取响应中的 `forecast` 或 `forecastHourly` URL 发起第二次请求。

本作业禁止使用要求接入厂商 SDK 的天气服务，也不得因某服务提供 SDK 就直接使用其 SDK。和风天气不作为本作业候选。即使选择其他 API，也必须满足“免费或有明确免费层、提供公开 HTTP/JSON 文档、允许 `NSURLSession` 直接访问”这三个条件。

</details>

## 基本要求

1. 只使用系统原生网络与解析能力：请求使用 `NSURLSession`，JSON 使用 `NSJSONSerialization` 并自行映射 Model；禁止 AFNetworking、Alamofire、YYModel、MJExtension、Mantle 及同类 SDK。
2. 使用 MVC：Model 保存和解析数据，View 负责展示，Controller 负责协调；网络请求必须集中封装在自建的单例网络层中。
3. 正确处理线程：耗时工作不阻塞主线程，所有 UI 更新回到主线程，并处理异步回调、页面生命周期和 Cell 复用问题。
4. 软件流程应完整且符合常理：成功、失败、加载中、空数据、重复操作、快速连续操作等情况均应有合理结果，不能崩溃或显示错乱。
5. 使用 AI Agent 辅助开发时，必须在仓库中建立并持续更新项目记忆文档；文档不得被 `.gitignore` 忽略，必须纳入 Git 版本控制。

> 验收看的是职责边界和实际行为，不是文件夹或类名是否“看起来像 MVC”。禁止把请求、JSON 解析和大量业务逻辑继续写在 ViewController 中，再用命名伪装成分层。

<details>
<summary>建议的最小项目结构（需要时展开）</summary>

```text
Project/
├── Models/          # 城市、天气等数据模型及解析
├── Views/           # 自定义 View / Cell，仅负责展示和交互出口
├── Controllers/     # 页面协调、状态驱动和导航
├── Services/
│   └── NetworkManager.*  # 自建 NSURLSession/URLSession 单例
└── Resources/       # 图片、配置等资源
```

网络单例至少应统一负责：URL/参数构造、发起与取消请求、HTTP 状态检查、错误传递、数据回调。业务接口可以放在独立 Service 中，但不得回到 Controller 内直接创建网络请求。

</details>

<details>
<summary>AI Agent 项目记忆文档（使用 AI 时展开）</summary>

使用 AI Agent 的同学应在仓库根目录创建 `PROJECT_MEMORY.md`（也可在 `docs/` 下使用含义明确的同类名称）。该文档用于让后续 Agent 和开发者快速恢复项目上下文，至少应记录：

- 当前需求、明确的禁止事项和验收标准；
- MVC 分层、网络单例、Model 结构及关键设计决定；
- 接口字段、城市唯一 Key、搜索竞态及五请求乱序处理方案；
- 已完成内容、当前问题、下一步任务和可复现的构建/测试命令；
- 每次重要修改的日期、原因及结果。

记忆文档应记录经过确认的项目事实和决定，不要粘贴冗长聊天记录，也不得写入 API Key、Token、账号、个人信息等秘密。源码发生重要变化时必须同步更新，过期或与实际代码矛盾的记忆文档视为无效。

文档必须位于项目仓库内且不匹配任何 `.gitignore` 规则。可使用以下命令确认：

```bash
git check-ignore PROJECT_MEMORY.md   # 正常应无输出
git ls-files PROJECT_MEMORY.md       # 提交或暂存后应能看到该文件
```

仅保存在 Agent 私有目录、编辑器缓存、临时文件夹或 `.gitignore` 排除目录中的记忆，不计入项目成果。

</details>

<details>
<summary>模糊搜索与城市防重复（需要时展开）</summary>

### 模糊搜索的 TableView 更新时机

搜索控件不作强制要求：可以使用 `UISearchBar`，也可以使用 `UITextField + UITableView` 自行实现搜索列表。若使用 `UITextField`，可监听 `UIControlEventEditingChanged`（或代理回调）取得实时输入。无论选择哪种控件，都必须自行完成模糊查询、结果展示和状态处理，不能用第三方搜索组件代替。

输入文字变化后不要立刻无节制地刷新或发送请求。建议等待用户停止输入约 300～500 ms（防抖）后再请求，并取消上一个未完成任务。每次请求保存搜索词和递增序号；回调到达时，只有当序号仍是最新且输入框文字仍匹配时，才能采用结果，避免旧关键词的慢请求覆盖新关键词的快请求。

- 输入为空：立即取消旧请求、清空数据源，并在主线程 `reloadData`。
- 请求成功：先在后台完成 JSON 解析和 Model 映射，再在主线程一次性替换数据源并 `reloadData`；不要每解析一条就刷新一次。
- 请求失败或无结果：在主线程更新为明确的错误或空状态，旧结果不能继续冒充当前结果。
- 更新顺序：必须先更新 TableView 的数据源，再调用 `reloadData`；数据源和 UI 更新应在同一主线程任务中完成。
- Cell 展示：Cell 只读取当前 Model；异步图片回调必须校验城市/图片 URL，防止复用后显示到错误行。

### 城市唯一性与重复添加

添加城市前必须查询唯一数据源。优先使用接口返回的稳定城市 ID；没有 ID 时，可使用规范化后的 `国家 + 行政区 + 城市 + 经纬度` 生成唯一 Key。不能只比较展示名称，因为不同地区可能有同名城市；也不能只比较当前 Cell 文本。

使用 `NSMutableSet` 或以唯一 Key 为键的 `NSMutableDictionary` 维护已添加城市。判重与写入必须在同一串行队列或主线程中作为一个不可分割的操作，避免连续点击时两个操作都先通过检查再重复写入。已存在时不发起重复请求、不修改数据源，并给出“该城市已添加”的反馈；添加成功后同步更新唯一性容器和页面，删除城市时也必须同步移除其 Key。

</details>

<details>
<summary>线程安全：多个请求乱序返回（需要时展开）</summary>

同时发送 5 个请求时，请求完成顺序是不确定的。例如发送顺序为 `A、B、C、D、E`，实际可能按 `C、A、E、B、D` 返回。如果每个回调都直接向同一个数组末尾追加数据，最终数组会变成返回顺序，页面内容就会错位；多个线程同时修改可变数组还可能产生数据竞争甚至崩溃。

应将“请求身份”与“结果”绑定，而不是依赖回调先后。可以在发送前保存稳定的请求顺序，并以城市 ID、请求 ID 或原始下标作为字典 Key：

```objc
NSArray *requestOrder = @[@"A", @"B", @"C", @"D", @"E"];
NSMutableDictionary *resultsByID = [NSMutableDictionary dictionary];
dispatch_queue_t stateQueue = dispatch_queue_create("com.example.weather.results", DISPATCH_QUEUE_SERIAL);
dispatch_group_t group = dispatch_group_create();

for (NSString *requestID in requestOrder) {
    dispatch_group_enter(group);
    [networkManager requestWithID:requestID completion:^(id result, NSError *error) {
        // 5 个回调都在同一串行队列写字典，不会并发修改。
        dispatch_async(stateQueue, ^{
            // 失败也保留占位，避免 B 失败后 C 被误放到 B 的位置。
            resultsByID[requestID] = result ?: [NSNull null];
            dispatch_group_leave(group);
        });
    }];
}

dispatch_group_notify(group, stateQueue, ^{
    NSMutableArray *orderedResults = [NSMutableArray array];
    for (NSString *requestID in requestOrder) {
        // 按 A、B、C、D、E 取值，而不是按 C、A、E、B、D 的完成顺序取值。
        [orderedResults addObject:resultsByID[requestID] ?: [NSNull null]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.items = orderedResults;
        [self.tableView reloadData];
    });
});
```

字典解决的是“结果属于哪个请求”，串行队列（或锁）解决的是“多个回调同时读写字典”的数据竞争，两者不能互相替代。可以用 `dispatch_group` 判断 5 个请求全部结束；字典的写入、读取和计数应集中在同一个串行队列，最终刷新 UI 必须切回主线程。

如果是搜索联想等“只认最新请求”的场景，则不应等待并重排全部结果：应取消旧请求，或比较递增的请求序号，只允许最新请求更新页面。缺失、失败或超时的请求也必须按其 Key 记录状态，不能因为少返回一项就让后续数据整体错位。

</details>

## 使用 AI Agent 验收

把下面提示词完整复制给能够读取项目文件并运行构建命令的 AI Agent：

<details>
<summary>展开并复制验收提示词</summary>

```text
你是一名严格但公平的 iOS 项目验收员。请检查当前工作区中的天气预报项目。先阅读 README、查看参考视频和全部工程结构，再检查源码、依赖配置和关键用户流程；如果环境允许，请执行一次构建或测试。视频只用于理解页面效果、交互方式和功能流程，不要求逐像素一致，也不得用视频推断代码架构；无法查看视频时标为“未验证”，继续完成源码审查。你的任务是审查并报告，不要直接修改代码。

验收目标：
0. 技术栈：项目应使用 Objective-C + UIKit，不得使用 SwiftUI 或跨平台框架代替要求中的实现。
1. 原生网络与解析：业务网络请求只能基于 NSURLSession，不得使用 AFNetworking、Alamofire 或其他网络请求/图片加载 SDK，也不得用 NSData dataWithContentsOfURL 等同步方式代替正规网络层。JSON 必须由 NSJSONSerialization 解析，并由开发者自行校验类型、处理缺失字段和映射 Model；禁止 YYModel、MJExtension、Mantle 及其他 JSON/Model 自动映射库。检查依赖配置、import 和实际调用，任一违规即不通过。
2. MVC：必须存在真实的数据 Model、展示 View 和协调 Controller。ViewController 不应直接拼 URL、创建 session/task、解析大段 JSON，Model 不应依赖 UIKit，View 不应发请求或持有业务数据源。不得仅靠目录或类名判定合格。
3. 网络单例：项目必须有开发者自行封装的网络管理单例；单例初始化应线程安全，并统一管理请求、参数、HTTP 状态码、解析/错误传递与取消能力。除该层外，搜索、天气和图片等业务代码不得直接创建 NSURLSession 或发起请求；如另建图片缓存/加载器，其底层请求仍须经过该网络单例，并检查线程与复用安全。
4. 线程安全：网络和较重解析不得阻塞主线程，UI 更新必须在主线程。重点模拟或追踪同时发送 5 个请求且按不同顺序返回的情况：代码不得把回调结果直接追加到共享数组并误把“完成顺序”当成“请求顺序”。应使用城市 ID、请求 ID 或原始下标等稳定 Key 将结果存入字典，再按原始顺序组装；共享字典/数组的读写必须由同一串行队列或锁保护，全部完成后再回主线程刷新 UI。另需检查 completion 的回调队列约定、部分失败/超时、页面退出后的回调、请求取消、搜索旧请求覆盖新结果、循环引用，以及 UITableView/UICollectionView Cell 复用导致的图片错位。注意：字典只能关联请求与结果，本身不能保证线程安全。
5. 业务逻辑：实际追踪“启动 → 模糊搜索城市 → 选择城市 → 展示天气 → 添加 → 防重复 → 查看 → 删除”的流程。搜索可使用 UISearchBar，也可使用 UITextField + UITableView 自行实现，不得仅因控件选择不同而扣分；重点检查模糊查询行为。搜索应有合理防抖；空输入立即清空；数据源必须先更新、TableView 后在主线程刷新；旧请求不得覆盖新关键词结果。城市应以稳定 ID 为唯一 Key，无 ID 时使用地区与经纬度组合，不能只用展示名称；判重与写入必须是同一串行操作，连续点击也只能添加一次，删除时同步清理 Key。另检查加载、空数据、无网络、超时、非 2xx、无效 JSON、字段缺失、数组越界等情况是否有合理反馈且不崩溃。
6. 基础质量：不得在仓库中提交真实 API Key 或其他秘密；URL 参数应安全编码；错误不能只 NSLog 后让界面无响应。检查命名、重复代码、资源管理和必要测试，但不要把个人代码风格当作硬性标准。
7. AI Agent 记忆（条件项）：从提交记录、项目说明或记忆文档判断是否使用了 AI Agent。若使用，必须存在 PROJECT_MEMORY.md 或同等用途文档，内容应与当前代码一致并记录需求、架构决定、并发方案、进度和验证命令；该文件必须位于仓库内、不受 .gitignore 排除且已由 Git 跟踪。用 git check-ignore 和 git ls-files 提供证据。不得将 API Key、Token 或个人信息写入记忆文档。未使用 AI Agent 时将本项标为“不适用”，不要扣分。
8. API 接入：所选天气服务必须提供可由 NSURLSession 直接访问的公开 HTTP/JSON 接口，不得接入任何厂商 SDK。检查实际免费层是否满足功能需要，例如 WeatherAPI 当前免费层只有 3 日预报；真实 API Key 不得出现在源码、记忆文档或 Git 历史中。

判定规则：
- 第 1、2、3 项任一不满足，整体直接判定“不通过”。
- 第 4、5 项若存在可能崩溃、卡住、数据显示错乱或严重竞态的问题，整体判定“不通过”。
- 不要因为“范例项目中也这样写”而放宽标准；范例只用于说明功能流程。
- 只根据实际读取到的文件和命令结果下结论。无法验证的内容标为“未验证”，不要猜测。

请按以下格式输出：
A. 总结：通过 / 有条件通过 / 不通过（一句话说明核心原因）
B. 评分：原生网络、MVC、网络单例、线程安全、业务逻辑各 20 分，总分 100
C. 证据表：每项给出结论、证据文件与行号、影响；同时列出做得好的地方
D. 必须修复：按 P0/P1 排序，给出最小可执行建议，不直接改代码
E. 建议改进：列出不影响通过的 P2 项
F. 验证记录：列出实际运行的构建/测试命令及结果；未运行时说明原因
G. 最终核对：明确回答是否使用了第三方网络库、是否真正采用 MVC、是否存在且实际使用自建网络单例、UI 是否始终在主线程更新、核心流程是否闭环
H. 并发专项：用 A、B、C、D、E 五个请求举例，说明项目在乱序返回及部分失败时如何保持数据身份和展示顺序；指出共享结果容器由什么机制保护。若代码没有对应机制，明确判为线程安全不合格
I. 搜索与判重专项：搜索控件可为 UISearchBar，也可为 UITextField + UITableView，不以控件类型判定优劣。说明模糊搜索的输入监听、防抖、取消/序号校验、数据源替换及 TableView 刷新时机；指出城市唯一 Key 的生成方式，并模拟连续点击两次添加和删除后重新添加。若旧响应能覆盖新结果或同一城市能重复添加，判为业务逻辑不合格
J. AI 记忆专项：若项目使用 AI Agent，给出记忆文档路径、内容时效性、git check-ignore 与 git ls-files 的实际结果，并检查其中是否包含秘密；缺失、被忽略、未跟踪或明显过期时判定该项不合格
K. API 来源专项：给出所用天气 API 的官方文档、免费层和调用方式，确认所有请求均为 NSURLSession 直接访问 HTTP/JSON 且未接入厂商 SDK；若免费层无法覆盖项目所展示的预报天数或功能，明确指出
```

</details>

## 暑假任务完成之后

🎉 恭喜大家完成本次暑假任务！完成天气项目后，也请开始构思自己明年准备参加比赛的项目：想解决什么问题、服务哪些用户、核心功能是什么，以及为什么值得做。形成大致想法后，主动向组长说明准备开发的方向。

明年的比赛项目原则上两人组队，必须使用 Git 进行多人协作开发。两位成员应共同参与需求、设计、编码、Review 和测试，通过各自分支与 Pull Request（或 Merge Request）协作，保留清晰、可追踪的提交记录；不要长期共用一个分支、一个账号或由一人完成全部代码。

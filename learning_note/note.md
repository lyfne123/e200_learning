### RISCV架构指令集

#### 指令集代号

| 代号 | 含义                                                        |
| ---- | ----------------------------------------------------------- |
| I    | 支持32个通用整数指令寄存器                                  |
| M    | 支持整数乘法与除法指令                                      |
| A    | 支持存储器原子操作指令和Load-Reserved/Store-Conditional指令 |
| F    | 支持单精度浮点指令                                          |
| D    | 支持双精度浮点指令                                          |
| C    | 支持16为压缩指令                                            |
| G    | IMAFD                                                       |
| E    | 嵌入式架构，只有16个通用整数指令寄存器，只支持32位架构      |

#### 寄存器组

I包含32个通用整数寄存器，标号x0 ~ x31，x0被预留为常数0

如果是32位架构，寄存器宽度为32,64位架构宽度则为64

E包含16个通用整数寄存器，标号x0 ~ x15，x0被预留为常数0

如果支持F或D，需要另外增加一组独立的通用浮点寄存器，标号f0 ~ f32

在汇编语言中，通用寄存器组中的每个寄存器均有别名

RV架构中的所有整数有符号数均由二进制补码表示

#### 工作模式

三种工作模式（特权模式）

| 模式            | 中文名   | 简称   | 是否可选 |
| --------------- | -------- | ------ | -------- |
| Machine Mode    | 机器模式 | M Mode | 必选     |
| Supervisor Mode | 监督模式 | S Mode | 可选     |
| User Mode       | 用户模式 | U Mode | 可选     |

只有机器模式的系统，一般为简单的嵌入式系统

支持机器模式与用户模式的系统，适合需要资源保护的嵌入式系统

三种模式都支持的系统可以用来运行类UNIX操作系统

#### 基本整数指令集(RV32I)

未明确说明的情况下，imm都进行符号扩展，再进行操作

| 指令    | 汇编格式                   | 解释                                                         |
| ------- | -------------------------- | ------------------------------------------------------------ |
| addi    | addi rd, rs1, imm[11:0]    | 将rs1与12位立即数进行加法操作，结果写回rd，如果溢出，直接抛弃溢出位 |
| slti    | slti rd, rs1, imm[11:0]    | 将rs1与12位立即数进行有符号数比较，结果写回rd，如果rs1小于imm，结果为1 |
| sltiu   | sltiu rd, rs1, imm[11:0]   | 将rs1与12位立即数进行无符号数比较，结果写回rd，如果rs1小于imm，结果为1 |
| andi    | andi rd, rs1, imm[11:0]    | 将rs1与12位立即数进行与操作，结果写回rd                      |
| ori     | ori rd, rs1, imm[11:0]     | 将rs1与12位立即数进行或操作，结果写回rd                      |
| xori    | xori rd, rs1, imm[11:0]    | 将rs1与12位立即数进行异或操作，结果写回rd                    |
| slli    | slli rd, rs1, shamt[4:0]   | 对rs1中的值进行逻辑左移操作，移位量为5位立即数，结果写回rd   |
| srli    | srli rd, rs1, shamt[4:0]   | 对rs1中的值进行逻辑右移操作，移位量为5位立即数，结果写回rd   |
| srai    | srai rd, rs1, shamt[4:0]   | 对rs1中的值进行算数右移操作，移位量为5位立即数，结果写回rd   |
| lui     | lui rd, imm                | 将20位立即数的值左移12为成为一个32位数，写回ed               |
| auipc   | auipc rd, imm              | 将20位立即数的值左移12位成为一个32位数，将此数与该指令的PC值相加，将加法结果写回rd |
| add     | add rd, rs1, rs2           | 将rs1与rs2进行加法操作，结果写回rd，如果溢出，直接抛弃溢出位 |
| sub     | sub rd, rs1, rs2           | 将rs1与rs2进行减法操作，结果写回rd，如果溢出，直接抛弃溢出位 |
| slt     | slt rd, rs1, rs2           | 将rs1与rs2当做有符号数进行比较操作，结果写回rd，如果rs1小于rs2，结果为1 |
| sltu    | sltu rd, rs1, rs2          | 将rs1与rs2当做无符号数进行比较操作，结果写回rd，如果rs1小于rs2，结果为1 |
| and     | and rd, rs1, rs2           | 将rs1与rs2进行与操作，结果写回rd                             |
| or      | or rd, rs1, rs2            | 将rs1与rs2进行或操作，结果写回rd                             |
| xor     | xor rd, rs1, rs2           | 将rs1与rs2进行异或操作，结果写回rd                           |
| sll     | sll rd, rs1, rs2           | 对rs1中的值进行逻辑左移操作，移位量为rs2中的低5位，结果写回rd |
| srl     | srl rd, rs1, rs2           | 对rs1中的值进行逻辑右移操作，移位量为rs2中的低5位，结果写回rd |
| sra     | sra rd, rs1, rs2           | 对rs1中的值进行算数右移操作，移位量为rs2中的低5位，结果写回rd |
| jal     | jal rd, label              | 使用20位立即数(有符号)作为偏移量，该偏移量乘以2，然后与该指令的pc相加，即为目标跳转地址。该指令仅可跳转到前后1MB的地址区间。该指令会将PC+4的值写入rd |
| jalr    | jalr rd, rs1, imm          | 使用12位立即数(有符号)作为偏移量，与rs1的值相加得到最终目标跳转地址。该指令会将PC+4的值写入rd |
| beq     | beq rs1, rs2, label        | 使用12位立即数(有符号)作为偏移量，该偏移量乘以2，然后与该指令的pc相加，即为目标跳转地址。该指令仅可跳转到前后4KB的地址区间。该指令在rs1与rs2值相等时跳转 |
| bne     | bne rs1, rs2, label        | 立即数同beq，该指令在rs1与rs2值不相等时跳转                  |
| blt     | blt rs1, rs2, label        | 立即数同beq，该指令在rs1有符号小于rs2的值时跳转              |
| bltu    | bltu rs1, rs2, label       | 立即数同beq，该指令在rs1无符号小于rs2的值时跳转              |
| bge     | bge rs1, rs2, label        | 立即数同beq，该指令在rs1有符号大于rs2的值时跳转              |
| bgeu    | bgeu rs1, rs2, label       | 立即数同beq，该指令在rs1无符号大于rs2的值时跳转              |
| lw      | lw rd, offset[11:0] (rs1)  | 访问地址由rs1的值与12位立即数相加所得，该指令从寄存器中读回一个32位数据，写回rd |
| lh      | lh rd, offset[11:0] (rs1)  | 访问地址同lw，该指令从寄存器中读回一个16位数据，进行符号位扩展后写回rd |
| lhu     | lhu rd, offset[11:0] (rs1) | 访问地址同lw，该指令从寄存器中读回一个16位数据，进行逻辑扩展后写回rd |
| lb      | lb rd, offset[11:0] (rs1)  | 访问地址同lw，该指令从寄存器中读回一个8位数据，进行符号位扩展后写回rd |
| lbu     | lbu rd, offset[11:0] (rs1) | 访问地址同lw，该指令从寄存器中读回一个8位数据，进行逻辑扩展后写回rd |
| sw      | sw rs2, offset[11:0] (rs1) | 访问地址同lw，将rs2中的32位数据写回存储器                    |
| sh      | sh rs2, offset[11:0] (rs1) | 访问地址同lw，将rs2中的低16位数据写回存储器                  |
| sb      | sb rs2, offset[11:0] (rs1) | 访问地址同lw，将rs2中的低8位数据写回存储器                   |
| csrrw   | csrrw rd, csr, rs1         | 将csr索引的CSR寄存器值读出，写回rd。将rs1中的值写入csr索引的CSR寄存器 |
| csrrs   | csrrs rd, csr, rs1         | 将csr索引的CSR寄存器值读出，写回rd。对rs1的值做逐位检查，如某位为1，则将csr索引的CSR寄存器中对应的位置为1，其他位不受影响 |
| csrrc   | csrrc rd, csr, rs1         | 将csr索引的CSR寄存器值读出，写回rd。对rs1的值做逐位检查，如某位为1，则将csr索引的CSR寄存器中对应的位置为0，其他位不受影响 |
| csrrwi  | csrrwi rd, csr, imm[4:0]   | 将csr索引的CSR寄存器值读出，写回rd。将5位立即数(高位补0扩展)的值写入csr索引的CSR寄存器 |
| csrrsi  | csrrsi rd, csr, imm[4:0]   | 将csr索引的CSR寄存器值读出，写回rd。对5位立即数(高位补0扩展)的值做逐位检查，如某位为1，则将csr索引的CSR寄存器中对应的位置为1，其他位不受影响 |
| csrrci  | csrrci rd, csr, imm[4:0]   | 将csr索引的CSR寄存器值读出，写回rd。对5位立即数(高位补0扩展)的值做逐位检查，如某位为1，则将csr索引的CSR寄存器中对应的位置为0，其他位不受影响 |
| fence   | fence xx, xx               | i: 设备读，o: 设备写，r: 存储器读，w: 存储器写。该指令保证“在fence之前所有指令进行的数据访存结果”必须比“在fence之后所有指令进行的数据访存结果”先被观测到 |
| fence.i | fence.i                    | 该指令保证“在fence.i之前所有指令进行的数据访存结果”一定能够被“在fence.i之后所有指令进行的取指令操作”访问到 |
| ecall   | ecall                      | 生成环境调用异常。当产生异常时，mepc寄存器会被更新为ecall指令本身的pc值 |
| ebreak  | ebreak                     | 生成断点异常。当产生异常时，mepc寄存器会被更新为ebreak指令本身的pc值 |
| mret    | mret                       | 退出异常。执行该指令后，处理器会跳转到mepc寄存器指定的pc地址，继续执行之前被中止的程序流 |
| wfi     | wfi                        | 等待中断。用于休眠，当处理器执行到wfi指令后，会进入空闲状态，直到接收到中断 |

#### 整数乘除法指令(RV32M)

| 指令   | 汇编格式 | 解释 |
| ------ | -------- | ---- |
| mul    |          |      |
| mulh   |          |      |
| mulhu  |          |      |
| mulhsu |          |      |
| div    |          |      |
| divu   |          |      |
| rem    |          |      |
| remu   |          |      |

#### 浮点指令(RV32F/D)

| 指令      | 汇编格式 | 解释 |
| --------- | -------- | ---- |
| flw       |          |      |
| fsw       |          |      |
| fld       |          |      |
| fsd       |          |      |
| fadd      |          |      |
| fsub      |          |      |
| fmul      |          |      |
| fdiv      |          |      |
| fsqrt     |          |      |
| fmin      |          |      |
| fmax      |          |      |
| fmadd     |          |      |
| fmsub     |          |      |
| fnmsub    |          |      |
| fnmadd    |          |      |
| fcvt.w.s  |          |      |
| fcvt.s.w  |          |      |
| fcvt.wu.s |          |      |
| fcvt.s.wu |          |      |
| fcvt.w.d  |          |      |
| fcvt.d.w  |          |      |
| fcvt.wu.d |          |      |
| fcvt.d.wu |          |      |
| fcvt.s.d  |          |      |
| fcvt.d.s  |          |      |
| fsgnj     |          |      |
| fsgnjn    |          |      |
| fsgnjx    |          |      |
| fmv.x.w   |          |      |
| fmv.w.x   |          |      |
| flt       |          |      |
| fle       |          |      |
| feq       |          |      |
| fclass    |          |      |

#### 存储器原子操作指令(RV32A)

| 指令      | 汇编格式 | 解释 |
| --------- | -------- | ---- |
| amoswap.w |          |      |
| amoadd.w  |          |      |
| amoand.w  |          |      |
| amoor.w   |          |      |
| amoxor.w  |          |      |
| amomax.w  |          |      |
| amomaxu.w |          |      |
| amomin.w  |          |      |
| amominu.w |          |      |
| lr.w      |          |      |
| sc.w      |          |      |

#### 16位压缩指令(RV32C)

#### 伪指令

### 开发笔记

Mini Decoder例化了一个完整的Decoder，通过将无关端口置0的方式，让综合器来进行电路优化。Chisel中可以直接通过参数化方式实现一个可配置的Decoder，而不依赖于工具的优化。

当前代码没有FPU，相关逻辑为冗余逻辑

### 可配置点
是否有bpu模块

是否支持压缩指令

是否支持整数乘法/除法指令

是否支持原子指令

是否支持csr指令

是否支持ALU内置乘除法

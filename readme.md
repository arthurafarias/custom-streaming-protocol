# Custom Streaming Protocol for FPGAs

This repository is intented to reunite all work I had developing a simple memory mapped hardware description components to develop streaming protocols for FPGA.

This protocol is a simplified version of a memory transfer protocol that allows easely create blocks for FPGA without signaling overhead of protocols like AXI4 and others.

## Timing Diagram

### Transfer Operation

![Timing Diagram 01](https://svg.wavedrom.com/github/arthurafarias/custom-streaming-protocol/master/docs/img/timing-00.json5)

```wavedrom
{signal: [
  {name: 'clk',  wave: 'p..|...|...'},
  {name: 'sync', wave: '0..|1.0|1.0'},
  {name: 'addr', wave: 'x.x|=.x|22x', data: ['addr', 'A0', 'A1']},
  {name: 'data', wave: 'x.x|=.x|22x', data: ['data', 'B0', 'B1']},
]}
```

Example for 1 byte bus

![Timing Diagram 01](https://svg.wavedrom.com/github/arthurafarias/custom-streaming-protocol/master/docs/img/timing-01.json5)
```wavedrom
{signal: [
  {name: 'clk',  wave: 'p..|...|...'},
  {name: 'sync', wave: '0..|1.0|1.0'},
  {name: 'addr', wave: 'x.x|=.x|22x', data: ['addr', '0x00', '0x01']},
  {name: 'data', wave: 'x.x|=.x|22x', data: ['data', 'B0', 'B1']},
]}
```

Example for 2 byte bus

![Timing Diagram 01](https://svg.wavedrom.com/github/arthurafarias/custom-streaming-protocol/master/docs/img/timing-02.json5)
```wavedrom
{signal: [
  {name: 'clk',  wave: 'p..|...|...'},
  {name: 'sync', wave: '0..|1.0|1.0'},
  {name: 'addr', wave: 'x.x|=.x|22x', data: ['addr', '0x00', '0x02']},
  {name: 'data', wave: 'x.x|=.x|22x', data: ['data', 'S0', 'S1']},
]}
```

Example for 4 bytes bus

![Timing Diagram 01](https://svg.wavedrom.com/github/arthurafarias/custom-streaming-protocol/master/docs/img/timing-03.json5)
```wavedrom
{signal: [
  {name: 'clk',  wave: 'p..|...|...'},
  {name: 'sync', wave: '0..|1.0|1.0'},
  {name: 'addr', wave: 'x.x|=.x|22x', data: ['addr', '0x00', '0x04']},
  {name: 'data', wave: 'x.x|=.x|22x', data: ['data', 'W0', 'W1']},
]}
```

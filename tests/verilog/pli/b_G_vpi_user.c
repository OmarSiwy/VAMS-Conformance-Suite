/* b G — vpi_user.h against Annex G's listing of it.
 *
 * IEEE 1364-2005:
 *
 * §1.7, p. 5: "The header file listings included in Annex G for vpi_user.h
 * are a normative part of this standard. All compliant software tools should
 * use the same function declarations, constant definitions, and structure
 * definitions contained in these header file listings."
 *
 * §20.8, p. 368: "The libraries of PLI functions are defined in a C include
 * file, which is a normative part of this standard. This file also defines
 * constants, structures, and other data used by the library of PLI routines
 * and the interface mechanisms. The file is vpi_user.h (listed in Annex G).
 * PLI applications that use the VPI routines shall include the file
 * vpi_user.h."
 *
 * Annex G, p. 522 ff.: the listing, whose `#define`s give every type,
 * property, constant and callback reason a number, and whose XXTERN lines
 * declare the routines.
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * Every `#define vpi...`/`#define cb...` of Annex G, 441 names, with its
 * value; the three written as expressions evaluate to vpiPosedge
 * (vpiEdgex1 | vpiEdge01 | vpiEdge0x) = 0x08|0x01|0x04 = 13, vpiNegedge
 * (vpiEdgex0 | vpiEdge10 | vpiEdge1x) = 0x20|0x02|0x10 = 50, vpiAnyEdge =
 * 13|50 = 63. For each name the header defines, its value must be Annex G's;
 * each name it does not define is counted. This application includes
 * vpi_user.h (§20.8) and uses nothing else to name a constant.
 *
 * The routines: the ten Annex G declares that are not already called by a
 * running fixture (vpi_control, vpi_flush, vpi_mcd_flush, vpi_vprintf,
 * vpi_mcd_vprintf, vpi_get_data, vpi_put_data, vpi_get_userdata,
 * vpi_put_userdata, vpi_handle_by_multi_index) are declared here with Annex
 * G's signatures as weak symbols: one the product does not provide links as
 * NULL and is counted.
 *
 * The include guard VPI_USER_H and the portability macros must be defined
 * (one check).
 *
 * The expected result is 0 missing names, 0 missing routines, and no
 * mismatch.
 */

//! inherited IEEE 1364-2005 G
//! inherited IEEE 1364-2005 20.8
//! design ../../verilog-ams/ch11_vpi/objects.v
//! stdout p02: b_G_vpi_user checks=444

#include <stdarg.h>
#include "b_check.h"

#define WEAK __attribute__((weak))
extern PLI_INT32 vpi_control(PLI_INT32 operation, ...) WEAK;
extern PLI_INT32 vpi_flush(void) WEAK;
extern PLI_INT32 vpi_mcd_flush(PLI_UINT32 mcd) WEAK;
extern PLI_INT32 vpi_vprintf(PLI_BYTE8 *format, va_list ap) WEAK;
extern PLI_INT32 vpi_mcd_vprintf(PLI_UINT32 mcd, PLI_BYTE8 *format, va_list ap) WEAK;
extern PLI_INT32 vpi_get_data(PLI_INT32 id, PLI_BYTE8 *dataLoc, PLI_INT32 numOfBytes) WEAK;
extern PLI_INT32 vpi_put_data(PLI_INT32 id, PLI_BYTE8 *dataLoc, PLI_INT32 numOfBytes) WEAK;
extern void *vpi_get_userdata(vpiHandle obj) WEAK;
extern PLI_INT32 vpi_put_userdata(vpiHandle obj, void *userdata) WEAK;
extern vpiHandle vpi_handle_by_multi_index(vpiHandle obj, PLI_INT32 num_index, PLI_INT32 *index_array) WEAK;

static void constants(void)
{
  static char msg[96];
  int missing = 0;
#ifdef vpiAlways
  CHECK(vpiAlways == 1, "G: vpiAlways is 1");
#else
  missing++;
#endif
#ifdef vpiAssignStmt
  CHECK(vpiAssignStmt == 2, "G: vpiAssignStmt is 2");
#else
  missing++;
#endif
#ifdef vpiAssignment
  CHECK(vpiAssignment == 3, "G: vpiAssignment is 3");
#else
  missing++;
#endif
#ifdef vpiBegin
  CHECK(vpiBegin == 4, "G: vpiBegin is 4");
#else
  missing++;
#endif
#ifdef vpiCase
  CHECK(vpiCase == 5, "G: vpiCase is 5");
#else
  missing++;
#endif
#ifdef vpiCaseItem
  CHECK(vpiCaseItem == 6, "G: vpiCaseItem is 6");
#else
  missing++;
#endif
#ifdef vpiConstant
  CHECK(vpiConstant == 7, "G: vpiConstant is 7");
#else
  missing++;
#endif
#ifdef vpiContAssign
  CHECK(vpiContAssign == 8, "G: vpiContAssign is 8");
#else
  missing++;
#endif
#ifdef vpiDeassign
  CHECK(vpiDeassign == 9, "G: vpiDeassign is 9");
#else
  missing++;
#endif
#ifdef vpiDefParam
  CHECK(vpiDefParam == 10, "G: vpiDefParam is 10");
#else
  missing++;
#endif
#ifdef vpiDelayControl
  CHECK(vpiDelayControl == 11, "G: vpiDelayControl is 11");
#else
  missing++;
#endif
#ifdef vpiDisable
  CHECK(vpiDisable == 12, "G: vpiDisable is 12");
#else
  missing++;
#endif
#ifdef vpiEventControl
  CHECK(vpiEventControl == 13, "G: vpiEventControl is 13");
#else
  missing++;
#endif
#ifdef vpiEventStmt
  CHECK(vpiEventStmt == 14, "G: vpiEventStmt is 14");
#else
  missing++;
#endif
#ifdef vpiFor
  CHECK(vpiFor == 15, "G: vpiFor is 15");
#else
  missing++;
#endif
#ifdef vpiForce
  CHECK(vpiForce == 16, "G: vpiForce is 16");
#else
  missing++;
#endif
#ifdef vpiForever
  CHECK(vpiForever == 17, "G: vpiForever is 17");
#else
  missing++;
#endif
#ifdef vpiFork
  CHECK(vpiFork == 18, "G: vpiFork is 18");
#else
  missing++;
#endif
#ifdef vpiFuncCall
  CHECK(vpiFuncCall == 19, "G: vpiFuncCall is 19");
#else
  missing++;
#endif
#ifdef vpiFunction
  CHECK(vpiFunction == 20, "G: vpiFunction is 20");
#else
  missing++;
#endif
#ifdef vpiGate
  CHECK(vpiGate == 21, "G: vpiGate is 21");
#else
  missing++;
#endif
#ifdef vpiIf
  CHECK(vpiIf == 22, "G: vpiIf is 22");
#else
  missing++;
#endif
#ifdef vpiIfElse
  CHECK(vpiIfElse == 23, "G: vpiIfElse is 23");
#else
  missing++;
#endif
#ifdef vpiInitial
  CHECK(vpiInitial == 24, "G: vpiInitial is 24");
#else
  missing++;
#endif
#ifdef vpiIntegerVar
  CHECK(vpiIntegerVar == 25, "G: vpiIntegerVar is 25");
#else
  missing++;
#endif
#ifdef vpiInterModPath
  CHECK(vpiInterModPath == 26, "G: vpiInterModPath is 26");
#else
  missing++;
#endif
#ifdef vpiIterator
  CHECK(vpiIterator == 27, "G: vpiIterator is 27");
#else
  missing++;
#endif
#ifdef vpiIODecl
  CHECK(vpiIODecl == 28, "G: vpiIODecl is 28");
#else
  missing++;
#endif
#ifdef vpiMemory
  CHECK(vpiMemory == 29, "G: vpiMemory is 29");
#else
  missing++;
#endif
#ifdef vpiMemoryWord
  CHECK(vpiMemoryWord == 30, "G: vpiMemoryWord is 30");
#else
  missing++;
#endif
#ifdef vpiModPath
  CHECK(vpiModPath == 31, "G: vpiModPath is 31");
#else
  missing++;
#endif
#ifdef vpiModule
  CHECK(vpiModule == 32, "G: vpiModule is 32");
#else
  missing++;
#endif
#ifdef vpiNamedBegin
  CHECK(vpiNamedBegin == 33, "G: vpiNamedBegin is 33");
#else
  missing++;
#endif
#ifdef vpiNamedEvent
  CHECK(vpiNamedEvent == 34, "G: vpiNamedEvent is 34");
#else
  missing++;
#endif
#ifdef vpiNamedFork
  CHECK(vpiNamedFork == 35, "G: vpiNamedFork is 35");
#else
  missing++;
#endif
#ifdef vpiNet
  CHECK(vpiNet == 36, "G: vpiNet is 36");
#else
  missing++;
#endif
#ifdef vpiNetBit
  CHECK(vpiNetBit == 37, "G: vpiNetBit is 37");
#else
  missing++;
#endif
#ifdef vpiNullStmt
  CHECK(vpiNullStmt == 38, "G: vpiNullStmt is 38");
#else
  missing++;
#endif
#ifdef vpiOperation
  CHECK(vpiOperation == 39, "G: vpiOperation is 39");
#else
  missing++;
#endif
#ifdef vpiParamAssign
  CHECK(vpiParamAssign == 40, "G: vpiParamAssign is 40");
#else
  missing++;
#endif
#ifdef vpiParameter
  CHECK(vpiParameter == 41, "G: vpiParameter is 41");
#else
  missing++;
#endif
#ifdef vpiPartSelect
  CHECK(vpiPartSelect == 42, "G: vpiPartSelect is 42");
#else
  missing++;
#endif
#ifdef vpiPathTerm
  CHECK(vpiPathTerm == 43, "G: vpiPathTerm is 43");
#else
  missing++;
#endif
#ifdef vpiPort
  CHECK(vpiPort == 44, "G: vpiPort is 44");
#else
  missing++;
#endif
#ifdef vpiPortBit
  CHECK(vpiPortBit == 45, "G: vpiPortBit is 45");
#else
  missing++;
#endif
#ifdef vpiPrimTerm
  CHECK(vpiPrimTerm == 46, "G: vpiPrimTerm is 46");
#else
  missing++;
#endif
#ifdef vpiRealVar
  CHECK(vpiRealVar == 47, "G: vpiRealVar is 47");
#else
  missing++;
#endif
#ifdef vpiReg
  CHECK(vpiReg == 48, "G: vpiReg is 48");
#else
  missing++;
#endif
#ifdef vpiRegBit
  CHECK(vpiRegBit == 49, "G: vpiRegBit is 49");
#else
  missing++;
#endif
#ifdef vpiRelease
  CHECK(vpiRelease == 50, "G: vpiRelease is 50");
#else
  missing++;
#endif
#ifdef vpiRepeat
  CHECK(vpiRepeat == 51, "G: vpiRepeat is 51");
#else
  missing++;
#endif
#ifdef vpiRepeatControl
  CHECK(vpiRepeatControl == 52, "G: vpiRepeatControl is 52");
#else
  missing++;
#endif
#ifdef vpiSchedEvent
  CHECK(vpiSchedEvent == 53, "G: vpiSchedEvent is 53");
#else
  missing++;
#endif
#ifdef vpiSpecParam
  CHECK(vpiSpecParam == 54, "G: vpiSpecParam is 54");
#else
  missing++;
#endif
#ifdef vpiSwitch
  CHECK(vpiSwitch == 55, "G: vpiSwitch is 55");
#else
  missing++;
#endif
#ifdef vpiSysFuncCall
  CHECK(vpiSysFuncCall == 56, "G: vpiSysFuncCall is 56");
#else
  missing++;
#endif
#ifdef vpiSysTaskCall
  CHECK(vpiSysTaskCall == 57, "G: vpiSysTaskCall is 57");
#else
  missing++;
#endif
#ifdef vpiTableEntry
  CHECK(vpiTableEntry == 58, "G: vpiTableEntry is 58");
#else
  missing++;
#endif
#ifdef vpiTask
  CHECK(vpiTask == 59, "G: vpiTask is 59");
#else
  missing++;
#endif
#ifdef vpiTaskCall
  CHECK(vpiTaskCall == 60, "G: vpiTaskCall is 60");
#else
  missing++;
#endif
#ifdef vpiTchk
  CHECK(vpiTchk == 61, "G: vpiTchk is 61");
#else
  missing++;
#endif
#ifdef vpiTchkTerm
  CHECK(vpiTchkTerm == 62, "G: vpiTchkTerm is 62");
#else
  missing++;
#endif
#ifdef vpiTimeVar
  CHECK(vpiTimeVar == 63, "G: vpiTimeVar is 63");
#else
  missing++;
#endif
#ifdef vpiTimeQueue
  CHECK(vpiTimeQueue == 64, "G: vpiTimeQueue is 64");
#else
  missing++;
#endif
#ifdef vpiUdp
  CHECK(vpiUdp == 65, "G: vpiUdp is 65");
#else
  missing++;
#endif
#ifdef vpiUdpDefn
  CHECK(vpiUdpDefn == 66, "G: vpiUdpDefn is 66");
#else
  missing++;
#endif
#ifdef vpiUserSystf
  CHECK(vpiUserSystf == 67, "G: vpiUserSystf is 67");
#else
  missing++;
#endif
#ifdef vpiVarSelect
  CHECK(vpiVarSelect == 68, "G: vpiVarSelect is 68");
#else
  missing++;
#endif
#ifdef vpiWait
  CHECK(vpiWait == 69, "G: vpiWait is 69");
#else
  missing++;
#endif
#ifdef vpiWhile
  CHECK(vpiWhile == 70, "G: vpiWhile is 70");
#else
  missing++;
#endif
#ifdef vpiAttribute
  CHECK(vpiAttribute == 105, "G: vpiAttribute is 105");
#else
  missing++;
#endif
#ifdef vpiBitSelect
  CHECK(vpiBitSelect == 106, "G: vpiBitSelect is 106");
#else
  missing++;
#endif
#ifdef vpiCallback
  CHECK(vpiCallback == 107, "G: vpiCallback is 107");
#else
  missing++;
#endif
#ifdef vpiDelayTerm
  CHECK(vpiDelayTerm == 108, "G: vpiDelayTerm is 108");
#else
  missing++;
#endif
#ifdef vpiDelayDevice
  CHECK(vpiDelayDevice == 109, "G: vpiDelayDevice is 109");
#else
  missing++;
#endif
#ifdef vpiFrame
  CHECK(vpiFrame == 110, "G: vpiFrame is 110");
#else
  missing++;
#endif
#ifdef vpiGateArray
  CHECK(vpiGateArray == 111, "G: vpiGateArray is 111");
#else
  missing++;
#endif
#ifdef vpiModuleArray
  CHECK(vpiModuleArray == 112, "G: vpiModuleArray is 112");
#else
  missing++;
#endif
#ifdef vpiPrimitiveArray
  CHECK(vpiPrimitiveArray == 113, "G: vpiPrimitiveArray is 113");
#else
  missing++;
#endif
#ifdef vpiNetArray
  CHECK(vpiNetArray == 114, "G: vpiNetArray is 114");
#else
  missing++;
#endif
#ifdef vpiRange
  CHECK(vpiRange == 115, "G: vpiRange is 115");
#else
  missing++;
#endif
#ifdef vpiRegArray
  CHECK(vpiRegArray == 116, "G: vpiRegArray is 116");
#else
  missing++;
#endif
#ifdef vpiSwitchArray
  CHECK(vpiSwitchArray == 117, "G: vpiSwitchArray is 117");
#else
  missing++;
#endif
#ifdef vpiUdpArray
  CHECK(vpiUdpArray == 118, "G: vpiUdpArray is 118");
#else
  missing++;
#endif
#ifdef vpiContAssignBit
  CHECK(vpiContAssignBit == 128, "G: vpiContAssignBit is 128");
#else
  missing++;
#endif
#ifdef vpiNamedEventArray
  CHECK(vpiNamedEventArray == 129, "G: vpiNamedEventArray is 129");
#else
  missing++;
#endif
#ifdef vpiIndexedPartSelect
  CHECK(vpiIndexedPartSelect == 130, "G: vpiIndexedPartSelect is 130");
#else
  missing++;
#endif
#ifdef vpiGenScopeArray
  CHECK(vpiGenScopeArray == 133, "G: vpiGenScopeArray is 133");
#else
  missing++;
#endif
#ifdef vpiGenScope
  CHECK(vpiGenScope == 134, "G: vpiGenScope is 134");
#else
  missing++;
#endif
#ifdef vpiGenVar
  CHECK(vpiGenVar == 135, "G: vpiGenVar is 135");
#else
  missing++;
#endif
#ifdef vpiCondition
  CHECK(vpiCondition == 71, "G: vpiCondition is 71");
#else
  missing++;
#endif
#ifdef vpiDelay
  CHECK(vpiDelay == 72, "G: vpiDelay is 72");
#else
  missing++;
#endif
#ifdef vpiElseStmt
  CHECK(vpiElseStmt == 73, "G: vpiElseStmt is 73");
#else
  missing++;
#endif
#ifdef vpiForIncStmt
  CHECK(vpiForIncStmt == 74, "G: vpiForIncStmt is 74");
#else
  missing++;
#endif
#ifdef vpiForInitStmt
  CHECK(vpiForInitStmt == 75, "G: vpiForInitStmt is 75");
#else
  missing++;
#endif
#ifdef vpiHighConn
  CHECK(vpiHighConn == 76, "G: vpiHighConn is 76");
#else
  missing++;
#endif
#ifdef vpiLhs
  CHECK(vpiLhs == 77, "G: vpiLhs is 77");
#else
  missing++;
#endif
#ifdef vpiIndex
  CHECK(vpiIndex == 78, "G: vpiIndex is 78");
#else
  missing++;
#endif
#ifdef vpiLeftRange
  CHECK(vpiLeftRange == 79, "G: vpiLeftRange is 79");
#else
  missing++;
#endif
#ifdef vpiLowConn
  CHECK(vpiLowConn == 80, "G: vpiLowConn is 80");
#else
  missing++;
#endif
#ifdef vpiParent
  CHECK(vpiParent == 81, "G: vpiParent is 81");
#else
  missing++;
#endif
#ifdef vpiRhs
  CHECK(vpiRhs == 82, "G: vpiRhs is 82");
#else
  missing++;
#endif
#ifdef vpiRightRange
  CHECK(vpiRightRange == 83, "G: vpiRightRange is 83");
#else
  missing++;
#endif
#ifdef vpiScope
  CHECK(vpiScope == 84, "G: vpiScope is 84");
#else
  missing++;
#endif
#ifdef vpiSysTfCall
  CHECK(vpiSysTfCall == 85, "G: vpiSysTfCall is 85");
#else
  missing++;
#endif
#ifdef vpiTchkDataTerm
  CHECK(vpiTchkDataTerm == 86, "G: vpiTchkDataTerm is 86");
#else
  missing++;
#endif
#ifdef vpiTchkNotifier
  CHECK(vpiTchkNotifier == 87, "G: vpiTchkNotifier is 87");
#else
  missing++;
#endif
#ifdef vpiTchkRefTerm
  CHECK(vpiTchkRefTerm == 88, "G: vpiTchkRefTerm is 88");
#else
  missing++;
#endif
#ifdef vpiArgument
  CHECK(vpiArgument == 89, "G: vpiArgument is 89");
#else
  missing++;
#endif
#ifdef vpiBit
  CHECK(vpiBit == 90, "G: vpiBit is 90");
#else
  missing++;
#endif
#ifdef vpiDriver
  CHECK(vpiDriver == 91, "G: vpiDriver is 91");
#else
  missing++;
#endif
#ifdef vpiInternalScope
  CHECK(vpiInternalScope == 92, "G: vpiInternalScope is 92");
#else
  missing++;
#endif
#ifdef vpiLoad
  CHECK(vpiLoad == 93, "G: vpiLoad is 93");
#else
  missing++;
#endif
#ifdef vpiModDataPathIn
  CHECK(vpiModDataPathIn == 94, "G: vpiModDataPathIn is 94");
#else
  missing++;
#endif
#ifdef vpiModPathIn
  CHECK(vpiModPathIn == 95, "G: vpiModPathIn is 95");
#else
  missing++;
#endif
#ifdef vpiModPathOut
  CHECK(vpiModPathOut == 96, "G: vpiModPathOut is 96");
#else
  missing++;
#endif
#ifdef vpiOperand
  CHECK(vpiOperand == 97, "G: vpiOperand is 97");
#else
  missing++;
#endif
#ifdef vpiPortInst
  CHECK(vpiPortInst == 98, "G: vpiPortInst is 98");
#else
  missing++;
#endif
#ifdef vpiProcess
  CHECK(vpiProcess == 99, "G: vpiProcess is 99");
#else
  missing++;
#endif
#ifdef vpiVariables
  CHECK(vpiVariables == 100, "G: vpiVariables is 100");
#else
  missing++;
#endif
#ifdef vpiUse
  CHECK(vpiUse == 101, "G: vpiUse is 101");
#else
  missing++;
#endif
#ifdef vpiExpr
  CHECK(vpiExpr == 102, "G: vpiExpr is 102");
#else
  missing++;
#endif
#ifdef vpiPrimitive
  CHECK(vpiPrimitive == 103, "G: vpiPrimitive is 103");
#else
  missing++;
#endif
#ifdef vpiStmt
  CHECK(vpiStmt == 104, "G: vpiStmt is 104");
#else
  missing++;
#endif
#ifdef vpiActiveTimeFormat
  CHECK(vpiActiveTimeFormat == 119, "G: vpiActiveTimeFormat is 119");
#else
  missing++;
#endif
#ifdef vpiInTerm
  CHECK(vpiInTerm == 120, "G: vpiInTerm is 120");
#else
  missing++;
#endif
#ifdef vpiInstanceArray
  CHECK(vpiInstanceArray == 121, "G: vpiInstanceArray is 121");
#else
  missing++;
#endif
#ifdef vpiLocalDriver
  CHECK(vpiLocalDriver == 122, "G: vpiLocalDriver is 122");
#else
  missing++;
#endif
#ifdef vpiLocalLoad
  CHECK(vpiLocalLoad == 123, "G: vpiLocalLoad is 123");
#else
  missing++;
#endif
#ifdef vpiOutTerm
  CHECK(vpiOutTerm == 124, "G: vpiOutTerm is 124");
#else
  missing++;
#endif
#ifdef vpiPorts
  CHECK(vpiPorts == 125, "G: vpiPorts is 125");
#else
  missing++;
#endif
#ifdef vpiSimNet
  CHECK(vpiSimNet == 126, "G: vpiSimNet is 126");
#else
  missing++;
#endif
#ifdef vpiTaskFunc
  CHECK(vpiTaskFunc == 127, "G: vpiTaskFunc is 127");
#else
  missing++;
#endif
#ifdef vpiBaseExpr
  CHECK(vpiBaseExpr == 131, "G: vpiBaseExpr is 131");
#else
  missing++;
#endif
#ifdef vpiWidthExpr
  CHECK(vpiWidthExpr == 132, "G: vpiWidthExpr is 132");
#else
  missing++;
#endif
#ifdef vpiUndefined
  CHECK(vpiUndefined == -1, "G: vpiUndefined is -1");
#else
  missing++;
#endif
#ifdef vpiType
  CHECK(vpiType == 1, "G: vpiType is 1");
#else
  missing++;
#endif
#ifdef vpiName
  CHECK(vpiName == 2, "G: vpiName is 2");
#else
  missing++;
#endif
#ifdef vpiFullName
  CHECK(vpiFullName == 3, "G: vpiFullName is 3");
#else
  missing++;
#endif
#ifdef vpiSize
  CHECK(vpiSize == 4, "G: vpiSize is 4");
#else
  missing++;
#endif
#ifdef vpiFile
  CHECK(vpiFile == 5, "G: vpiFile is 5");
#else
  missing++;
#endif
#ifdef vpiLineNo
  CHECK(vpiLineNo == 6, "G: vpiLineNo is 6");
#else
  missing++;
#endif
#ifdef vpiTopModule
  CHECK(vpiTopModule == 7, "G: vpiTopModule is 7");
#else
  missing++;
#endif
#ifdef vpiCellInstance
  CHECK(vpiCellInstance == 8, "G: vpiCellInstance is 8");
#else
  missing++;
#endif
#ifdef vpiDefName
  CHECK(vpiDefName == 9, "G: vpiDefName is 9");
#else
  missing++;
#endif
#ifdef vpiProtected
  CHECK(vpiProtected == 10, "G: vpiProtected is 10");
#else
  missing++;
#endif
#ifdef vpiTimeUnit
  CHECK(vpiTimeUnit == 11, "G: vpiTimeUnit is 11");
#else
  missing++;
#endif
#ifdef vpiTimePrecision
  CHECK(vpiTimePrecision == 12, "G: vpiTimePrecision is 12");
#else
  missing++;
#endif
#ifdef vpiDefNetType
  CHECK(vpiDefNetType == 13, "G: vpiDefNetType is 13");
#else
  missing++;
#endif
#ifdef vpiUnconnDrive
  CHECK(vpiUnconnDrive == 14, "G: vpiUnconnDrive is 14");
#else
  missing++;
#endif
#ifdef vpiHighZ
  CHECK(vpiHighZ == 1, "G: vpiHighZ is 1");
#else
  missing++;
#endif
#ifdef vpiPull1
  CHECK(vpiPull1 == 2, "G: vpiPull1 is 2");
#else
  missing++;
#endif
#ifdef vpiPull0
  CHECK(vpiPull0 == 3, "G: vpiPull0 is 3");
#else
  missing++;
#endif
#ifdef vpiDefFile
  CHECK(vpiDefFile == 15, "G: vpiDefFile is 15");
#else
  missing++;
#endif
#ifdef vpiDefLineNo
  CHECK(vpiDefLineNo == 16, "G: vpiDefLineNo is 16");
#else
  missing++;
#endif
#ifdef vpiDefDelayMode
  CHECK(vpiDefDelayMode == 47, "G: vpiDefDelayMode is 47");
#else
  missing++;
#endif
#ifdef vpiDelayModeNone
  CHECK(vpiDelayModeNone == 1, "G: vpiDelayModeNone is 1");
#else
  missing++;
#endif
#ifdef vpiDelayModePath
  CHECK(vpiDelayModePath == 2, "G: vpiDelayModePath is 2");
#else
  missing++;
#endif
#ifdef vpiDelayModeDistrib
  CHECK(vpiDelayModeDistrib == 3, "G: vpiDelayModeDistrib is 3");
#else
  missing++;
#endif
#ifdef vpiDelayModeUnit
  CHECK(vpiDelayModeUnit == 4, "G: vpiDelayModeUnit is 4");
#else
  missing++;
#endif
#ifdef vpiDelayModeZero
  CHECK(vpiDelayModeZero == 5, "G: vpiDelayModeZero is 5");
#else
  missing++;
#endif
#ifdef vpiDelayModeMTM
  CHECK(vpiDelayModeMTM == 6, "G: vpiDelayModeMTM is 6");
#else
  missing++;
#endif
#ifdef vpiDefDecayTime
  CHECK(vpiDefDecayTime == 48, "G: vpiDefDecayTime is 48");
#else
  missing++;
#endif
#ifdef vpiScalar
  CHECK(vpiScalar == 17, "G: vpiScalar is 17");
#else
  missing++;
#endif
#ifdef vpiVector
  CHECK(vpiVector == 18, "G: vpiVector is 18");
#else
  missing++;
#endif
#ifdef vpiExplicitName
  CHECK(vpiExplicitName == 19, "G: vpiExplicitName is 19");
#else
  missing++;
#endif
#ifdef vpiDirection
  CHECK(vpiDirection == 20, "G: vpiDirection is 20");
#else
  missing++;
#endif
#ifdef vpiInput
  CHECK(vpiInput == 1, "G: vpiInput is 1");
#else
  missing++;
#endif
#ifdef vpiOutput
  CHECK(vpiOutput == 2, "G: vpiOutput is 2");
#else
  missing++;
#endif
#ifdef vpiInout
  CHECK(vpiInout == 3, "G: vpiInout is 3");
#else
  missing++;
#endif
#ifdef vpiMixedIO
  CHECK(vpiMixedIO == 4, "G: vpiMixedIO is 4");
#else
  missing++;
#endif
#ifdef vpiNoDirection
  CHECK(vpiNoDirection == 5, "G: vpiNoDirection is 5");
#else
  missing++;
#endif
#ifdef vpiConnByName
  CHECK(vpiConnByName == 21, "G: vpiConnByName is 21");
#else
  missing++;
#endif
#ifdef vpiNetType
  CHECK(vpiNetType == 22, "G: vpiNetType is 22");
#else
  missing++;
#endif
#ifdef vpiWire
  CHECK(vpiWire == 1, "G: vpiWire is 1");
#else
  missing++;
#endif
#ifdef vpiWand
  CHECK(vpiWand == 2, "G: vpiWand is 2");
#else
  missing++;
#endif
#ifdef vpiWor
  CHECK(vpiWor == 3, "G: vpiWor is 3");
#else
  missing++;
#endif
#ifdef vpiTri
  CHECK(vpiTri == 4, "G: vpiTri is 4");
#else
  missing++;
#endif
#ifdef vpiTri0
  CHECK(vpiTri0 == 5, "G: vpiTri0 is 5");
#else
  missing++;
#endif
#ifdef vpiTri1
  CHECK(vpiTri1 == 6, "G: vpiTri1 is 6");
#else
  missing++;
#endif
#ifdef vpiTriReg
  CHECK(vpiTriReg == 7, "G: vpiTriReg is 7");
#else
  missing++;
#endif
#ifdef vpiTriAnd
  CHECK(vpiTriAnd == 8, "G: vpiTriAnd is 8");
#else
  missing++;
#endif
#ifdef vpiTriOr
  CHECK(vpiTriOr == 9, "G: vpiTriOr is 9");
#else
  missing++;
#endif
#ifdef vpiSupply1
  CHECK(vpiSupply1 == 10, "G: vpiSupply1 is 10");
#else
  missing++;
#endif
#ifdef vpiSupply0
  CHECK(vpiSupply0 == 11, "G: vpiSupply0 is 11");
#else
  missing++;
#endif
#ifdef vpiNone
  CHECK(vpiNone == 12, "G: vpiNone is 12");
#else
  missing++;
#endif
#ifdef vpiUwire
  CHECK(vpiUwire == 13, "G: vpiUwire is 13");
#else
  missing++;
#endif
#ifdef vpiExplicitScalared
  CHECK(vpiExplicitScalared == 23, "G: vpiExplicitScalared is 23");
#else
  missing++;
#endif
#ifdef vpiExplicitVectored
  CHECK(vpiExplicitVectored == 24, "G: vpiExplicitVectored is 24");
#else
  missing++;
#endif
#ifdef vpiExpanded
  CHECK(vpiExpanded == 25, "G: vpiExpanded is 25");
#else
  missing++;
#endif
#ifdef vpiImplicitDecl
  CHECK(vpiImplicitDecl == 26, "G: vpiImplicitDecl is 26");
#else
  missing++;
#endif
#ifdef vpiChargeStrength
  CHECK(vpiChargeStrength == 27, "G: vpiChargeStrength is 27");
#else
  missing++;
#endif
#ifdef vpiLargeCharge
  CHECK(vpiLargeCharge == 16, "G: vpiLargeCharge is 16");
#else
  missing++;
#endif
#ifdef vpiMediumCharge
  CHECK(vpiMediumCharge == 4, "G: vpiMediumCharge is 4");
#else
  missing++;
#endif
#ifdef vpiSmallCharge
  CHECK(vpiSmallCharge == 2, "G: vpiSmallCharge is 2");
#else
  missing++;
#endif
#ifdef vpiArray
  CHECK(vpiArray == 28, "G: vpiArray is 28");
#else
  missing++;
#endif
#ifdef vpiPortIndex
  CHECK(vpiPortIndex == 29, "G: vpiPortIndex is 29");
#else
  missing++;
#endif
#ifdef vpiTermIndex
  CHECK(vpiTermIndex == 30, "G: vpiTermIndex is 30");
#else
  missing++;
#endif
#ifdef vpiStrength0
  CHECK(vpiStrength0 == 31, "G: vpiStrength0 is 31");
#else
  missing++;
#endif
#ifdef vpiStrength1
  CHECK(vpiStrength1 == 32, "G: vpiStrength1 is 32");
#else
  missing++;
#endif
#ifdef vpiPrimType
  CHECK(vpiPrimType == 33, "G: vpiPrimType is 33");
#else
  missing++;
#endif
#ifdef vpiAndPrim
  CHECK(vpiAndPrim == 1, "G: vpiAndPrim is 1");
#else
  missing++;
#endif
#ifdef vpiNandPrim
  CHECK(vpiNandPrim == 2, "G: vpiNandPrim is 2");
#else
  missing++;
#endif
#ifdef vpiNorPrim
  CHECK(vpiNorPrim == 3, "G: vpiNorPrim is 3");
#else
  missing++;
#endif
#ifdef vpiOrPrim
  CHECK(vpiOrPrim == 4, "G: vpiOrPrim is 4");
#else
  missing++;
#endif
#ifdef vpiXorPrim
  CHECK(vpiXorPrim == 5, "G: vpiXorPrim is 5");
#else
  missing++;
#endif
#ifdef vpiXnorPrim
  CHECK(vpiXnorPrim == 6, "G: vpiXnorPrim is 6");
#else
  missing++;
#endif
#ifdef vpiBufPrim
  CHECK(vpiBufPrim == 7, "G: vpiBufPrim is 7");
#else
  missing++;
#endif
#ifdef vpiNotPrim
  CHECK(vpiNotPrim == 8, "G: vpiNotPrim is 8");
#else
  missing++;
#endif
#ifdef vpiBufif0Prim
  CHECK(vpiBufif0Prim == 9, "G: vpiBufif0Prim is 9");
#else
  missing++;
#endif
#ifdef vpiBufif1Prim
  CHECK(vpiBufif1Prim == 10, "G: vpiBufif1Prim is 10");
#else
  missing++;
#endif
#ifdef vpiNotif0Prim
  CHECK(vpiNotif0Prim == 11, "G: vpiNotif0Prim is 11");
#else
  missing++;
#endif
#ifdef vpiNotif1Prim
  CHECK(vpiNotif1Prim == 12, "G: vpiNotif1Prim is 12");
#else
  missing++;
#endif
#ifdef vpiNmosPrim
  CHECK(vpiNmosPrim == 13, "G: vpiNmosPrim is 13");
#else
  missing++;
#endif
#ifdef vpiPmosPrim
  CHECK(vpiPmosPrim == 14, "G: vpiPmosPrim is 14");
#else
  missing++;
#endif
#ifdef vpiCmosPrim
  CHECK(vpiCmosPrim == 15, "G: vpiCmosPrim is 15");
#else
  missing++;
#endif
#ifdef vpiRnmosPrim
  CHECK(vpiRnmosPrim == 16, "G: vpiRnmosPrim is 16");
#else
  missing++;
#endif
#ifdef vpiRpmosPrim
  CHECK(vpiRpmosPrim == 17, "G: vpiRpmosPrim is 17");
#else
  missing++;
#endif
#ifdef vpiRcmosPrim
  CHECK(vpiRcmosPrim == 18, "G: vpiRcmosPrim is 18");
#else
  missing++;
#endif
#ifdef vpiRtranPrim
  CHECK(vpiRtranPrim == 19, "G: vpiRtranPrim is 19");
#else
  missing++;
#endif
#ifdef vpiRtranif0Prim
  CHECK(vpiRtranif0Prim == 20, "G: vpiRtranif0Prim is 20");
#else
  missing++;
#endif
#ifdef vpiRtranif1Prim
  CHECK(vpiRtranif1Prim == 21, "G: vpiRtranif1Prim is 21");
#else
  missing++;
#endif
#ifdef vpiTranPrim
  CHECK(vpiTranPrim == 22, "G: vpiTranPrim is 22");
#else
  missing++;
#endif
#ifdef vpiTranif0Prim
  CHECK(vpiTranif0Prim == 23, "G: vpiTranif0Prim is 23");
#else
  missing++;
#endif
#ifdef vpiTranif1Prim
  CHECK(vpiTranif1Prim == 24, "G: vpiTranif1Prim is 24");
#else
  missing++;
#endif
#ifdef vpiPullupPrim
  CHECK(vpiPullupPrim == 25, "G: vpiPullupPrim is 25");
#else
  missing++;
#endif
#ifdef vpiPulldownPrim
  CHECK(vpiPulldownPrim == 26, "G: vpiPulldownPrim is 26");
#else
  missing++;
#endif
#ifdef vpiSeqPrim
  CHECK(vpiSeqPrim == 27, "G: vpiSeqPrim is 27");
#else
  missing++;
#endif
#ifdef vpiCombPrim
  CHECK(vpiCombPrim == 28, "G: vpiCombPrim is 28");
#else
  missing++;
#endif
#ifdef vpiPolarity
  CHECK(vpiPolarity == 34, "G: vpiPolarity is 34");
#else
  missing++;
#endif
#ifdef vpiDataPolarity
  CHECK(vpiDataPolarity == 35, "G: vpiDataPolarity is 35");
#else
  missing++;
#endif
#ifdef vpiPositive
  CHECK(vpiPositive == 1, "G: vpiPositive is 1");
#else
  missing++;
#endif
#ifdef vpiNegative
  CHECK(vpiNegative == 2, "G: vpiNegative is 2");
#else
  missing++;
#endif
#ifdef vpiUnknown
  CHECK(vpiUnknown == 3, "G: vpiUnknown is 3");
#else
  missing++;
#endif
#ifdef vpiEdge
  CHECK(vpiEdge == 36, "G: vpiEdge is 36");
#else
  missing++;
#endif
#ifdef vpiNoEdge
  CHECK(vpiNoEdge == 0, "G: vpiNoEdge is 0");
#else
  missing++;
#endif
#ifdef vpiEdge01
  CHECK(vpiEdge01 == 1, "G: vpiEdge01 is 1");
#else
  missing++;
#endif
#ifdef vpiEdge10
  CHECK(vpiEdge10 == 2, "G: vpiEdge10 is 2");
#else
  missing++;
#endif
#ifdef vpiEdge0x
  CHECK(vpiEdge0x == 4, "G: vpiEdge0x is 4");
#else
  missing++;
#endif
#ifdef vpiEdgex1
  CHECK(vpiEdgex1 == 8, "G: vpiEdgex1 is 8");
#else
  missing++;
#endif
#ifdef vpiEdge1x
  CHECK(vpiEdge1x == 16, "G: vpiEdge1x is 16");
#else
  missing++;
#endif
#ifdef vpiEdgex0
  CHECK(vpiEdgex0 == 32, "G: vpiEdgex0 is 32");
#else
  missing++;
#endif
#ifdef vpiPathType
  CHECK(vpiPathType == 37, "G: vpiPathType is 37");
#else
  missing++;
#endif
#ifdef vpiPathFull
  CHECK(vpiPathFull == 1, "G: vpiPathFull is 1");
#else
  missing++;
#endif
#ifdef vpiPathParallel
  CHECK(vpiPathParallel == 2, "G: vpiPathParallel is 2");
#else
  missing++;
#endif
#ifdef vpiTchkType
  CHECK(vpiTchkType == 38, "G: vpiTchkType is 38");
#else
  missing++;
#endif
#ifdef vpiSetup
  CHECK(vpiSetup == 1, "G: vpiSetup is 1");
#else
  missing++;
#endif
#ifdef vpiHold
  CHECK(vpiHold == 2, "G: vpiHold is 2");
#else
  missing++;
#endif
#ifdef vpiPeriod
  CHECK(vpiPeriod == 3, "G: vpiPeriod is 3");
#else
  missing++;
#endif
#ifdef vpiWidth
  CHECK(vpiWidth == 4, "G: vpiWidth is 4");
#else
  missing++;
#endif
#ifdef vpiSkew
  CHECK(vpiSkew == 5, "G: vpiSkew is 5");
#else
  missing++;
#endif
#ifdef vpiRecovery
  CHECK(vpiRecovery == 6, "G: vpiRecovery is 6");
#else
  missing++;
#endif
#ifdef vpiNoChange
  CHECK(vpiNoChange == 7, "G: vpiNoChange is 7");
#else
  missing++;
#endif
#ifdef vpiSetupHold
  CHECK(vpiSetupHold == 8, "G: vpiSetupHold is 8");
#else
  missing++;
#endif
#ifdef vpiFullskew
  CHECK(vpiFullskew == 9, "G: vpiFullskew is 9");
#else
  missing++;
#endif
#ifdef vpiRecrem
  CHECK(vpiRecrem == 10, "G: vpiRecrem is 10");
#else
  missing++;
#endif
#ifdef vpiRemoval
  CHECK(vpiRemoval == 11, "G: vpiRemoval is 11");
#else
  missing++;
#endif
#ifdef vpiTimeskew
  CHECK(vpiTimeskew == 12, "G: vpiTimeskew is 12");
#else
  missing++;
#endif
#ifdef vpiOpType
  CHECK(vpiOpType == 39, "G: vpiOpType is 39");
#else
  missing++;
#endif
#ifdef vpiMinusOp
  CHECK(vpiMinusOp == 1, "G: vpiMinusOp is 1");
#else
  missing++;
#endif
#ifdef vpiPlusOp
  CHECK(vpiPlusOp == 2, "G: vpiPlusOp is 2");
#else
  missing++;
#endif
#ifdef vpiNotOp
  CHECK(vpiNotOp == 3, "G: vpiNotOp is 3");
#else
  missing++;
#endif
#ifdef vpiBitNegOp
  CHECK(vpiBitNegOp == 4, "G: vpiBitNegOp is 4");
#else
  missing++;
#endif
#ifdef vpiUnaryAndOp
  CHECK(vpiUnaryAndOp == 5, "G: vpiUnaryAndOp is 5");
#else
  missing++;
#endif
#ifdef vpiUnaryNandOp
  CHECK(vpiUnaryNandOp == 6, "G: vpiUnaryNandOp is 6");
#else
  missing++;
#endif
#ifdef vpiUnaryOrOp
  CHECK(vpiUnaryOrOp == 7, "G: vpiUnaryOrOp is 7");
#else
  missing++;
#endif
#ifdef vpiUnaryNorOp
  CHECK(vpiUnaryNorOp == 8, "G: vpiUnaryNorOp is 8");
#else
  missing++;
#endif
#ifdef vpiUnaryXorOp
  CHECK(vpiUnaryXorOp == 9, "G: vpiUnaryXorOp is 9");
#else
  missing++;
#endif
#ifdef vpiUnaryXNorOp
  CHECK(vpiUnaryXNorOp == 10, "G: vpiUnaryXNorOp is 10");
#else
  missing++;
#endif
#ifdef vpiSubOp
  CHECK(vpiSubOp == 11, "G: vpiSubOp is 11");
#else
  missing++;
#endif
#ifdef vpiDivOp
  CHECK(vpiDivOp == 12, "G: vpiDivOp is 12");
#else
  missing++;
#endif
#ifdef vpiModOp
  CHECK(vpiModOp == 13, "G: vpiModOp is 13");
#else
  missing++;
#endif
#ifdef vpiEqOp
  CHECK(vpiEqOp == 14, "G: vpiEqOp is 14");
#else
  missing++;
#endif
#ifdef vpiNeqOp
  CHECK(vpiNeqOp == 15, "G: vpiNeqOp is 15");
#else
  missing++;
#endif
#ifdef vpiCaseEqOp
  CHECK(vpiCaseEqOp == 16, "G: vpiCaseEqOp is 16");
#else
  missing++;
#endif
#ifdef vpiCaseNeqOp
  CHECK(vpiCaseNeqOp == 17, "G: vpiCaseNeqOp is 17");
#else
  missing++;
#endif
#ifdef vpiGtOp
  CHECK(vpiGtOp == 18, "G: vpiGtOp is 18");
#else
  missing++;
#endif
#ifdef vpiGeOp
  CHECK(vpiGeOp == 19, "G: vpiGeOp is 19");
#else
  missing++;
#endif
#ifdef vpiLtOp
  CHECK(vpiLtOp == 20, "G: vpiLtOp is 20");
#else
  missing++;
#endif
#ifdef vpiLeOp
  CHECK(vpiLeOp == 21, "G: vpiLeOp is 21");
#else
  missing++;
#endif
#ifdef vpiLShiftOp
  CHECK(vpiLShiftOp == 22, "G: vpiLShiftOp is 22");
#else
  missing++;
#endif
#ifdef vpiRShiftOp
  CHECK(vpiRShiftOp == 23, "G: vpiRShiftOp is 23");
#else
  missing++;
#endif
#ifdef vpiAddOp
  CHECK(vpiAddOp == 24, "G: vpiAddOp is 24");
#else
  missing++;
#endif
#ifdef vpiMultOp
  CHECK(vpiMultOp == 25, "G: vpiMultOp is 25");
#else
  missing++;
#endif
#ifdef vpiLogAndOp
  CHECK(vpiLogAndOp == 26, "G: vpiLogAndOp is 26");
#else
  missing++;
#endif
#ifdef vpiLogOrOp
  CHECK(vpiLogOrOp == 27, "G: vpiLogOrOp is 27");
#else
  missing++;
#endif
#ifdef vpiBitAndOp
  CHECK(vpiBitAndOp == 28, "G: vpiBitAndOp is 28");
#else
  missing++;
#endif
#ifdef vpiBitOrOp
  CHECK(vpiBitOrOp == 29, "G: vpiBitOrOp is 29");
#else
  missing++;
#endif
#ifdef vpiBitXorOp
  CHECK(vpiBitXorOp == 30, "G: vpiBitXorOp is 30");
#else
  missing++;
#endif
#ifdef vpiBitXNorOp
  CHECK(vpiBitXNorOp == 31, "G: vpiBitXNorOp is 31");
#else
  missing++;
#endif
#ifdef vpiBitXnorOp
  CHECK(vpiBitXnorOp == 31, "G: vpiBitXnorOp is 31");
#else
  missing++;
#endif
#ifdef vpiConditionOp
  CHECK(vpiConditionOp == 32, "G: vpiConditionOp is 32");
#else
  missing++;
#endif
#ifdef vpiConcatOp
  CHECK(vpiConcatOp == 33, "G: vpiConcatOp is 33");
#else
  missing++;
#endif
#ifdef vpiMultiConcatOp
  CHECK(vpiMultiConcatOp == 34, "G: vpiMultiConcatOp is 34");
#else
  missing++;
#endif
#ifdef vpiEventOrOp
  CHECK(vpiEventOrOp == 35, "G: vpiEventOrOp is 35");
#else
  missing++;
#endif
#ifdef vpiNullOp
  CHECK(vpiNullOp == 36, "G: vpiNullOp is 36");
#else
  missing++;
#endif
#ifdef vpiListOp
  CHECK(vpiListOp == 37, "G: vpiListOp is 37");
#else
  missing++;
#endif
#ifdef vpiMinTypMaxOp
  CHECK(vpiMinTypMaxOp == 38, "G: vpiMinTypMaxOp is 38");
#else
  missing++;
#endif
#ifdef vpiPosedgeOp
  CHECK(vpiPosedgeOp == 39, "G: vpiPosedgeOp is 39");
#else
  missing++;
#endif
#ifdef vpiNegedgeOp
  CHECK(vpiNegedgeOp == 40, "G: vpiNegedgeOp is 40");
#else
  missing++;
#endif
#ifdef vpiArithLShiftOp
  CHECK(vpiArithLShiftOp == 41, "G: vpiArithLShiftOp is 41");
#else
  missing++;
#endif
#ifdef vpiArithRShiftOp
  CHECK(vpiArithRShiftOp == 42, "G: vpiArithRShiftOp is 42");
#else
  missing++;
#endif
#ifdef vpiPowerOp
  CHECK(vpiPowerOp == 43, "G: vpiPowerOp is 43");
#else
  missing++;
#endif
#ifdef vpiConstType
  CHECK(vpiConstType == 40, "G: vpiConstType is 40");
#else
  missing++;
#endif
#ifdef vpiDecConst
  CHECK(vpiDecConst == 1, "G: vpiDecConst is 1");
#else
  missing++;
#endif
#ifdef vpiRealConst
  CHECK(vpiRealConst == 2, "G: vpiRealConst is 2");
#else
  missing++;
#endif
#ifdef vpiBinaryConst
  CHECK(vpiBinaryConst == 3, "G: vpiBinaryConst is 3");
#else
  missing++;
#endif
#ifdef vpiOctConst
  CHECK(vpiOctConst == 4, "G: vpiOctConst is 4");
#else
  missing++;
#endif
#ifdef vpiHexConst
  CHECK(vpiHexConst == 5, "G: vpiHexConst is 5");
#else
  missing++;
#endif
#ifdef vpiStringConst
  CHECK(vpiStringConst == 6, "G: vpiStringConst is 6");
#else
  missing++;
#endif
#ifdef vpiIntConst
  CHECK(vpiIntConst == 7, "G: vpiIntConst is 7");
#else
  missing++;
#endif
#ifdef vpiTimeConst
  CHECK(vpiTimeConst == 8, "G: vpiTimeConst is 8");
#else
  missing++;
#endif
#ifdef vpiBlocking
  CHECK(vpiBlocking == 41, "G: vpiBlocking is 41");
#else
  missing++;
#endif
#ifdef vpiCaseType
  CHECK(vpiCaseType == 42, "G: vpiCaseType is 42");
#else
  missing++;
#endif
#ifdef vpiCaseExact
  CHECK(vpiCaseExact == 1, "G: vpiCaseExact is 1");
#else
  missing++;
#endif
#ifdef vpiCaseX
  CHECK(vpiCaseX == 2, "G: vpiCaseX is 2");
#else
  missing++;
#endif
#ifdef vpiCaseZ
  CHECK(vpiCaseZ == 3, "G: vpiCaseZ is 3");
#else
  missing++;
#endif
#ifdef vpiNetDeclAssign
  CHECK(vpiNetDeclAssign == 43, "G: vpiNetDeclAssign is 43");
#else
  missing++;
#endif
#ifdef vpiFuncType
  CHECK(vpiFuncType == 44, "G: vpiFuncType is 44");
#else
  missing++;
#endif
#ifdef vpiIntFunc
  CHECK(vpiIntFunc == 1, "G: vpiIntFunc is 1");
#else
  missing++;
#endif
#ifdef vpiRealFunc
  CHECK(vpiRealFunc == 2, "G: vpiRealFunc is 2");
#else
  missing++;
#endif
#ifdef vpiTimeFunc
  CHECK(vpiTimeFunc == 3, "G: vpiTimeFunc is 3");
#else
  missing++;
#endif
#ifdef vpiSizedFunc
  CHECK(vpiSizedFunc == 4, "G: vpiSizedFunc is 4");
#else
  missing++;
#endif
#ifdef vpiSizedSignedFunc
  CHECK(vpiSizedSignedFunc == 5, "G: vpiSizedSignedFunc is 5");
#else
  missing++;
#endif
#ifdef vpiSysFuncType
  CHECK(vpiSysFuncType == 44, "G: vpiSysFuncType is 44");
#else
  missing++;
#endif
#ifdef vpiSysFuncInt
  CHECK(vpiSysFuncInt == 1, "G: vpiSysFuncInt is 1");
#else
  missing++;
#endif
#ifdef vpiSysFuncReal
  CHECK(vpiSysFuncReal == 2, "G: vpiSysFuncReal is 2");
#else
  missing++;
#endif
#ifdef vpiSysFuncTime
  CHECK(vpiSysFuncTime == 3, "G: vpiSysFuncTime is 3");
#else
  missing++;
#endif
#ifdef vpiSysFuncSized
  CHECK(vpiSysFuncSized == 4, "G: vpiSysFuncSized is 4");
#else
  missing++;
#endif
#ifdef vpiUserDefn
  CHECK(vpiUserDefn == 45, "G: vpiUserDefn is 45");
#else
  missing++;
#endif
#ifdef vpiScheduled
  CHECK(vpiScheduled == 46, "G: vpiScheduled is 46");
#else
  missing++;
#endif
#ifdef vpiActive
  CHECK(vpiActive == 49, "G: vpiActive is 49");
#else
  missing++;
#endif
#ifdef vpiAutomatic
  CHECK(vpiAutomatic == 50, "G: vpiAutomatic is 50");
#else
  missing++;
#endif
#ifdef vpiCell
  CHECK(vpiCell == 51, "G: vpiCell is 51");
#else
  missing++;
#endif
#ifdef vpiConfig
  CHECK(vpiConfig == 52, "G: vpiConfig is 52");
#else
  missing++;
#endif
#ifdef vpiConstantSelect
  CHECK(vpiConstantSelect == 53, "G: vpiConstantSelect is 53");
#else
  missing++;
#endif
#ifdef vpiDecompile
  CHECK(vpiDecompile == 54, "G: vpiDecompile is 54");
#else
  missing++;
#endif
#ifdef vpiDefAttribute
  CHECK(vpiDefAttribute == 55, "G: vpiDefAttribute is 55");
#else
  missing++;
#endif
#ifdef vpiDelayType
  CHECK(vpiDelayType == 56, "G: vpiDelayType is 56");
#else
  missing++;
#endif
#ifdef vpiModPathDelay
  CHECK(vpiModPathDelay == 1, "G: vpiModPathDelay is 1");
#else
  missing++;
#endif
#ifdef vpiInterModPathDelay
  CHECK(vpiInterModPathDelay == 2, "G: vpiInterModPathDelay is 2");
#else
  missing++;
#endif
#ifdef vpiMIPDelay
  CHECK(vpiMIPDelay == 3, "G: vpiMIPDelay is 3");
#else
  missing++;
#endif
#ifdef vpiIteratorType
  CHECK(vpiIteratorType == 57, "G: vpiIteratorType is 57");
#else
  missing++;
#endif
#ifdef vpiLibrary
  CHECK(vpiLibrary == 58, "G: vpiLibrary is 58");
#else
  missing++;
#endif
#ifdef vpiMultiArray
  CHECK(vpiMultiArray == 59, "G: vpiMultiArray is 59");
#else
  missing++;
#endif
#ifdef vpiOffset
  CHECK(vpiOffset == 60, "G: vpiOffset is 60");
#else
  missing++;
#endif
#ifdef vpiResolvedNetType
  CHECK(vpiResolvedNetType == 61, "G: vpiResolvedNetType is 61");
#else
  missing++;
#endif
#ifdef vpiSaveRestartID
  CHECK(vpiSaveRestartID == 62, "G: vpiSaveRestartID is 62");
#else
  missing++;
#endif
#ifdef vpiSaveRestartLocation
  CHECK(vpiSaveRestartLocation == 63, "G: vpiSaveRestartLocation is 63");
#else
  missing++;
#endif
#ifdef vpiValid
  CHECK(vpiValid == 64, "G: vpiValid is 64");
#else
  missing++;
#endif
#ifdef vpiValidFalse
  CHECK(vpiValidFalse == 0, "G: vpiValidFalse is 0");
#else
  missing++;
#endif
#ifdef vpiValidTrue
  CHECK(vpiValidTrue == 1, "G: vpiValidTrue is 1");
#else
  missing++;
#endif
#ifdef vpiSigned
  CHECK(vpiSigned == 65, "G: vpiSigned is 65");
#else
  missing++;
#endif
#ifdef vpiLocalParam
  CHECK(vpiLocalParam == 70, "G: vpiLocalParam is 70");
#else
  missing++;
#endif
#ifdef vpiModPathHasIfNone
  CHECK(vpiModPathHasIfNone == 71, "G: vpiModPathHasIfNone is 71");
#else
  missing++;
#endif
#ifdef vpiIndexedPartSelectType
  CHECK(vpiIndexedPartSelectType == 72, "G: vpiIndexedPartSelectType is 72");
#else
  missing++;
#endif
#ifdef vpiPosIndexed
  CHECK(vpiPosIndexed == 1, "G: vpiPosIndexed is 1");
#else
  missing++;
#endif
#ifdef vpiNegIndexed
  CHECK(vpiNegIndexed == 2, "G: vpiNegIndexed is 2");
#else
  missing++;
#endif
#ifdef vpiIsMemory
  CHECK(vpiIsMemory == 73, "G: vpiIsMemory is 73");
#else
  missing++;
#endif
#ifdef vpiStop
  CHECK(vpiStop == 66, "G: vpiStop is 66");
#else
  missing++;
#endif
#ifdef vpiFinish
  CHECK(vpiFinish == 67, "G: vpiFinish is 67");
#else
  missing++;
#endif
#ifdef vpiReset
  CHECK(vpiReset == 68, "G: vpiReset is 68");
#else
  missing++;
#endif
#ifdef vpiSetInteractiveScope
  CHECK(vpiSetInteractiveScope == 69, "G: vpiSetInteractiveScope is 69");
#else
  missing++;
#endif
#ifdef vpiScaledRealTime
  CHECK(vpiScaledRealTime == 1, "G: vpiScaledRealTime is 1");
#else
  missing++;
#endif
#ifdef vpiSimTime
  CHECK(vpiSimTime == 2, "G: vpiSimTime is 2");
#else
  missing++;
#endif
#ifdef vpiSuppressTime
  CHECK(vpiSuppressTime == 3, "G: vpiSuppressTime is 3");
#else
  missing++;
#endif
#ifdef vpiSupplyDrive
  CHECK(vpiSupplyDrive == 128, "G: vpiSupplyDrive is 128");
#else
  missing++;
#endif
#ifdef vpiStrongDrive
  CHECK(vpiStrongDrive == 64, "G: vpiStrongDrive is 64");
#else
  missing++;
#endif
#ifdef vpiPullDrive
  CHECK(vpiPullDrive == 32, "G: vpiPullDrive is 32");
#else
  missing++;
#endif
#ifdef vpiWeakDrive
  CHECK(vpiWeakDrive == 8, "G: vpiWeakDrive is 8");
#else
  missing++;
#endif
#ifdef vpiHiZ
  CHECK(vpiHiZ == 1, "G: vpiHiZ is 1");
#else
  missing++;
#endif
#ifdef vpiBinStrVal
  CHECK(vpiBinStrVal == 1, "G: vpiBinStrVal is 1");
#else
  missing++;
#endif
#ifdef vpiOctStrVal
  CHECK(vpiOctStrVal == 2, "G: vpiOctStrVal is 2");
#else
  missing++;
#endif
#ifdef vpiDecStrVal
  CHECK(vpiDecStrVal == 3, "G: vpiDecStrVal is 3");
#else
  missing++;
#endif
#ifdef vpiHexStrVal
  CHECK(vpiHexStrVal == 4, "G: vpiHexStrVal is 4");
#else
  missing++;
#endif
#ifdef vpiScalarVal
  CHECK(vpiScalarVal == 5, "G: vpiScalarVal is 5");
#else
  missing++;
#endif
#ifdef vpiIntVal
  CHECK(vpiIntVal == 6, "G: vpiIntVal is 6");
#else
  missing++;
#endif
#ifdef vpiRealVal
  CHECK(vpiRealVal == 7, "G: vpiRealVal is 7");
#else
  missing++;
#endif
#ifdef vpiStringVal
  CHECK(vpiStringVal == 8, "G: vpiStringVal is 8");
#else
  missing++;
#endif
#ifdef vpiVectorVal
  CHECK(vpiVectorVal == 9, "G: vpiVectorVal is 9");
#else
  missing++;
#endif
#ifdef vpiStrengthVal
  CHECK(vpiStrengthVal == 10, "G: vpiStrengthVal is 10");
#else
  missing++;
#endif
#ifdef vpiTimeVal
  CHECK(vpiTimeVal == 11, "G: vpiTimeVal is 11");
#else
  missing++;
#endif
#ifdef vpiObjTypeVal
  CHECK(vpiObjTypeVal == 12, "G: vpiObjTypeVal is 12");
#else
  missing++;
#endif
#ifdef vpiSuppressVal
  CHECK(vpiSuppressVal == 13, "G: vpiSuppressVal is 13");
#else
  missing++;
#endif
#ifdef vpiNoDelay
  CHECK(vpiNoDelay == 1, "G: vpiNoDelay is 1");
#else
  missing++;
#endif
#ifdef vpiInertialDelay
  CHECK(vpiInertialDelay == 2, "G: vpiInertialDelay is 2");
#else
  missing++;
#endif
#ifdef vpiTransportDelay
  CHECK(vpiTransportDelay == 3, "G: vpiTransportDelay is 3");
#else
  missing++;
#endif
#ifdef vpiPureTransportDelay
  CHECK(vpiPureTransportDelay == 4, "G: vpiPureTransportDelay is 4");
#else
  missing++;
#endif
#ifdef vpiForceFlag
  CHECK(vpiForceFlag == 5, "G: vpiForceFlag is 5");
#else
  missing++;
#endif
#ifdef vpiReleaseFlag
  CHECK(vpiReleaseFlag == 6, "G: vpiReleaseFlag is 6");
#else
  missing++;
#endif
#ifdef vpiCancelEvent
  CHECK(vpiCancelEvent == 7, "G: vpiCancelEvent is 7");
#else
  missing++;
#endif
#ifdef vpiReturnEvent
  CHECK(vpiReturnEvent == 4096, "G: vpiReturnEvent is 4096");
#else
  missing++;
#endif
#ifdef vpi0
  CHECK(vpi0 == 0, "G: vpi0 is 0");
#else
  missing++;
#endif
#ifdef vpi1
  CHECK(vpi1 == 1, "G: vpi1 is 1");
#else
  missing++;
#endif
#ifdef vpiZ
  CHECK(vpiZ == 2, "G: vpiZ is 2");
#else
  missing++;
#endif
#ifdef vpiX
  CHECK(vpiX == 3, "G: vpiX is 3");
#else
  missing++;
#endif
#ifdef vpiH
  CHECK(vpiH == 4, "G: vpiH is 4");
#else
  missing++;
#endif
#ifdef vpiL
  CHECK(vpiL == 5, "G: vpiL is 5");
#else
  missing++;
#endif
#ifdef vpiDontCare
  CHECK(vpiDontCare == 6, "G: vpiDontCare is 6");
#else
  missing++;
#endif
#ifdef vpiSysTask
  CHECK(vpiSysTask == 1, "G: vpiSysTask is 1");
#else
  missing++;
#endif
#ifdef vpiSysFunc
  CHECK(vpiSysFunc == 2, "G: vpiSysFunc is 2");
#else
  missing++;
#endif
#ifdef vpiCompile
  CHECK(vpiCompile == 1, "G: vpiCompile is 1");
#else
  missing++;
#endif
#ifdef vpiPLI
  CHECK(vpiPLI == 2, "G: vpiPLI is 2");
#else
  missing++;
#endif
#ifdef vpiRun
  CHECK(vpiRun == 3, "G: vpiRun is 3");
#else
  missing++;
#endif
#ifdef vpiNotice
  CHECK(vpiNotice == 1, "G: vpiNotice is 1");
#else
  missing++;
#endif
#ifdef vpiWarning
  CHECK(vpiWarning == 2, "G: vpiWarning is 2");
#else
  missing++;
#endif
#ifdef vpiError
  CHECK(vpiError == 3, "G: vpiError is 3");
#else
  missing++;
#endif
#ifdef vpiSystem
  CHECK(vpiSystem == 4, "G: vpiSystem is 4");
#else
  missing++;
#endif
#ifdef vpiInternal
  CHECK(vpiInternal == 5, "G: vpiInternal is 5");
#else
  missing++;
#endif
#ifdef cbValueChange
  CHECK(cbValueChange == 1, "G: cbValueChange is 1");
#else
  missing++;
#endif
#ifdef cbStmt
  CHECK(cbStmt == 2, "G: cbStmt is 2");
#else
  missing++;
#endif
#ifdef cbForce
  CHECK(cbForce == 3, "G: cbForce is 3");
#else
  missing++;
#endif
#ifdef cbRelease
  CHECK(cbRelease == 4, "G: cbRelease is 4");
#else
  missing++;
#endif
#ifdef cbAtStartOfSimTime
  CHECK(cbAtStartOfSimTime == 5, "G: cbAtStartOfSimTime is 5");
#else
  missing++;
#endif
#ifdef cbReadWriteSynch
  CHECK(cbReadWriteSynch == 6, "G: cbReadWriteSynch is 6");
#else
  missing++;
#endif
#ifdef cbReadOnlySynch
  CHECK(cbReadOnlySynch == 7, "G: cbReadOnlySynch is 7");
#else
  missing++;
#endif
#ifdef cbNextSimTime
  CHECK(cbNextSimTime == 8, "G: cbNextSimTime is 8");
#else
  missing++;
#endif
#ifdef cbAfterDelay
  CHECK(cbAfterDelay == 9, "G: cbAfterDelay is 9");
#else
  missing++;
#endif
#ifdef cbEndOfCompile
  CHECK(cbEndOfCompile == 10, "G: cbEndOfCompile is 10");
#else
  missing++;
#endif
#ifdef cbStartOfSimulation
  CHECK(cbStartOfSimulation == 11, "G: cbStartOfSimulation is 11");
#else
  missing++;
#endif
#ifdef cbEndOfSimulation
  CHECK(cbEndOfSimulation == 12, "G: cbEndOfSimulation is 12");
#else
  missing++;
#endif
#ifdef cbError
  CHECK(cbError == 13, "G: cbError is 13");
#else
  missing++;
#endif
#ifdef cbTchkViolation
  CHECK(cbTchkViolation == 14, "G: cbTchkViolation is 14");
#else
  missing++;
#endif
#ifdef cbStartOfSave
  CHECK(cbStartOfSave == 15, "G: cbStartOfSave is 15");
#else
  missing++;
#endif
#ifdef cbEndOfSave
  CHECK(cbEndOfSave == 16, "G: cbEndOfSave is 16");
#else
  missing++;
#endif
#ifdef cbStartOfRestart
  CHECK(cbStartOfRestart == 17, "G: cbStartOfRestart is 17");
#else
  missing++;
#endif
#ifdef cbEndOfRestart
  CHECK(cbEndOfRestart == 18, "G: cbEndOfRestart is 18");
#else
  missing++;
#endif
#ifdef cbStartOfReset
  CHECK(cbStartOfReset == 19, "G: cbStartOfReset is 19");
#else
  missing++;
#endif
#ifdef cbEndOfReset
  CHECK(cbEndOfReset == 20, "G: cbEndOfReset is 20");
#else
  missing++;
#endif
#ifdef cbEnterInteractive
  CHECK(cbEnterInteractive == 21, "G: cbEnterInteractive is 21");
#else
  missing++;
#endif
#ifdef cbExitInteractive
  CHECK(cbExitInteractive == 22, "G: cbExitInteractive is 22");
#else
  missing++;
#endif
#ifdef cbInteractiveScopeChange
  CHECK(cbInteractiveScopeChange == 23, "G: cbInteractiveScopeChange is 23");
#else
  missing++;
#endif
#ifdef cbUnresolvedSystf
  CHECK(cbUnresolvedSystf == 24, "G: cbUnresolvedSystf is 24");
#else
  missing++;
#endif
#ifdef cbAssign
  CHECK(cbAssign == 25, "G: cbAssign is 25");
#else
  missing++;
#endif
#ifdef cbDeassign
  CHECK(cbDeassign == 26, "G: cbDeassign is 26");
#else
  missing++;
#endif
#ifdef cbDisable
  CHECK(cbDisable == 27, "G: cbDisable is 27");
#else
  missing++;
#endif
#ifdef cbPLIError
  CHECK(cbPLIError == 28, "G: cbPLIError is 28");
#else
  missing++;
#endif
#ifdef cbSignal
  CHECK(cbSignal == 29, "G: cbSignal is 29");
#else
  missing++;
#endif
#ifdef vpiPosedge
  CHECK(vpiPosedge == 13, "G: vpiPosedge is 13");
#else
  missing++;
#endif
#ifdef vpiNegedge
  CHECK(vpiNegedge == 50, "G: vpiNegedge is 50");
#else
  missing++;
#endif
#ifdef vpiAnyEdge
  CHECK(vpiAnyEdge == 63, "G: vpiAnyEdge is 63");
#else
  missing++;
#endif
  snprintf(msg, sizeof msg, "%d of Annex G's 441 constant names are not defined", missing);
  XFAIL(missing == 0, "G", msg);
}

/* Annex G's include guard and portability block (PLI_DLLISPEC, PLI_DLLESPEC,
 * PLI_EXTERN, PLI_VEXTERN, PLI_PROTOTYPES, PROTO_PARAMS, XXTERN, EETERN) name
 * no question an application asks, so the header defines all of them. One
 * check. */
static void macros(void)
{
#if defined(VPI_USER_H) && defined(PLI_TYPES) && defined(PLI_DLLISPEC) && defined(PLI_DLLESPEC) && \
    defined(PLI_EXTERN) && defined(PLI_VEXTERN) && defined(PLI_PROTOTYPES) && defined(PROTO_PARAMS) && \
    defined(XXTERN) && defined(EETERN)
  CHECK(1, "G: the include guard and the portability macros are defined");
#else
  CHECK(0, "G: the include guard and the portability macros are defined");
#endif
}

static void routines(void)
{
  static char msg[96];
  int missing = !vpi_control + !vpi_flush + !vpi_mcd_flush + !vpi_vprintf + !vpi_mcd_vprintf +
                !vpi_get_data + !vpi_put_data + !vpi_get_userdata + !vpi_put_userdata +
                !vpi_handle_by_multi_index;
  snprintf(msg, sizeof msg, "%d of Annex G's routines are not provided", missing);
  XFAIL(missing == 0, "G", msg);
}

static void startup(void)
{
  constants();
  macros();
  routines();
  p02_done("b_G_vpi_user");
}

void (*vlog_startup_routines[])(void) = { startup, 0 };

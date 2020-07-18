; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%printf_t = type { i64 }
%printf_t.0 = type { i64 }

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) section "s_kprobe:f_1" {
entry:
  %helper_error_t9 = alloca %helper_error_t
  %key4 = alloca i32
  %helper_error_t = alloca %helper_error_t
  %key = alloca i32
  %get_pid_tgid = call i64 inttoptr (i64 14 to i64 ()*)()
  %1 = lshr i64 %get_pid_tgid, 32
  %2 = icmp ugt i64 %1, 10
  %3 = zext i1 %2 to i64
  %true_cond = icmp ne i64 %3, 0
  br i1 %true_cond, label %if_body, label %else_body

if_body:                                          ; preds = %entry
  %4 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %4)
  store i32 0, i32* %key
  %pseudo = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %lookup_fmtstr_map = call %printf_t* inttoptr (i64 1 to %printf_t* (i64, i32*)*)(i64 %pseudo, i32* %key)
  %5 = sext %printf_t* %lookup_fmtstr_map to i32
  %6 = icmp ne i32 %5, 0
  br i1 %6, label %helper_merge, label %helper_failure

if_end:                                           ; preds = %helper_merge8, %helper_merge
  ret i64 0

else_body:                                        ; preds = %entry
  %7 = bitcast i32* %key4 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %7)
  store i32 0, i32* %key4
  %pseudo5 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %lookup_fmtstr_map6 = call %printf_t.0* inttoptr (i64 1 to %printf_t.0* (i64, i32*)*)(i64 %pseudo5, i32* %key4)
  %8 = sext %printf_t.0* %lookup_fmtstr_map6 to i32
  %9 = icmp ne i32 %8, 0
  br i1 %9, label %helper_merge8, label %helper_failure7

helper_failure:                                   ; preds = %if_body
  %10 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %10)
  %11 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %11
  %12 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %12
  %13 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 %5, i32* %13
  %14 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %14
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* %helper_error_t, i64 21)
  %15 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %15)
  ret i64 0

helper_merge:                                     ; preds = %if_body
  %16 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %16, i64 0, i64 8, i1 false)
  %17 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 0
  store i64 0, i64* %17
  %pseudo2 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output3 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t*, i64)*)(i8* %0, i64 %pseudo2, i64 4294967295, %printf_t* %lookup_fmtstr_map, i64 8)
  %18 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %18)
  br label %if_end

helper_failure7:                                  ; preds = %else_body
  %19 = bitcast %helper_error_t* %helper_error_t9 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %19)
  %20 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t9, i64 0, i32 0
  store i64 30006, i64* %20
  %21 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t9, i64 0, i32 1
  store i64 1, i64* %21
  %22 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t9, i64 0, i32 2
  store i32 %8, i32* %22
  %23 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t9, i64 0, i32 3
  store i8 1, i8* %23
  %pseudo10 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output11 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo10, i64 4294967295, %helper_error_t* %helper_error_t9, i64 21)
  %24 = bitcast %helper_error_t* %helper_error_t9 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %24)
  ret i64 0

helper_merge8:                                    ; preds = %else_body
  %25 = bitcast %printf_t.0* %lookup_fmtstr_map6 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %25, i64 0, i64 8, i1 false)
  %26 = getelementptr %printf_t.0, %printf_t.0* %lookup_fmtstr_map6, i32 0, i32 0
  store i64 1, i64* %26
  %pseudo12 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output13 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t.0*, i64)*)(i8* %0, i64 %pseudo12, i64 4294967295, %printf_t.0* %lookup_fmtstr_map6, i64 8)
  %27 = bitcast %printf_t.0* %lookup_fmtstr_map6 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %27)
  br label %if_end
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }

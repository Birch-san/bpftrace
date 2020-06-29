; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%printf_t = type <{ i64 }>
%printf_t.0 = type <{ i64 }>

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) local_unnamed_addr section "s_kprobe:f_1" {
entry:
  %helper_error_t9 = alloca %helper_error_t, align 8
  %key4 = alloca i32, align 4
  %helper_error_t = alloca %helper_error_t, align 8
  %key = alloca i32, align 4
  %get_pid_tgid = tail call i64 inttoptr (i64 14 to i64 ()*)()
  %1 = icmp ugt i64 %get_pid_tgid, 47244640255
  br i1 %1, label %if_body, label %else_body

if_body:                                          ; preds = %entry
  %2 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %2)
  store i32 0, i32* %key, align 4
  %pseudo = tail call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %lookup_fmtstr_map = call %printf_t* inttoptr (i64 1 to %printf_t* (i64, i32*)*)(i64 %pseudo, i32* nonnull %key)
  %3 = icmp eq %printf_t* %lookup_fmtstr_map, null
  br i1 %3, label %helper_failure, label %helper_merge

if_end:                                           ; preds = %helper_merge8, %helper_merge
  ret i64 0

else_body:                                        ; preds = %entry
  %4 = bitcast i32* %key4 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %4)
  store i32 0, i32* %key4, align 4
  %pseudo5 = tail call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %lookup_fmtstr_map6 = call %printf_t.0* inttoptr (i64 1 to %printf_t.0* (i64, i32*)*)(i64 %pseudo5, i32* nonnull %key4)
  %5 = icmp eq %printf_t.0* %lookup_fmtstr_map6, null
  br i1 %5, label %helper_failure7, label %helper_merge8

helper_failure:                                   ; preds = %if_body
  %6 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %6)
  %7 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %7, align 8
  %8 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %8, align 8
  %9 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 0, i32* %9, align 8
  %10 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %10, align 4
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* nonnull %helper_error_t, i64 21)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %6)
  ret i64 0

helper_merge:                                     ; preds = %if_body
  %probe_read = call i64 inttoptr (i64 4 to i64 (%printf_t*, i32, %printf_t*)*)(%printf_t* nonnull %lookup_fmtstr_map, i32 8, %printf_t* inttoptr (i64 140695077684784 to %printf_t*))
  %11 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i64 0, i32 0
  store i64 0, i64* %11, align 8
  %pseudo2 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output3 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t*, i64)*)(i8* %0, i64 %pseudo2, i64 4294967295, %printf_t* nonnull %lookup_fmtstr_map, i64 8)
  %12 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %12)
  br label %if_end

helper_failure7:                                  ; preds = %else_body
  %13 = bitcast %helper_error_t* %helper_error_t9 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %13)
  %14 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t9, i64 0, i32 0
  store i64 30006, i64* %14, align 8
  %15 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t9, i64 0, i32 1
  store i64 1, i64* %15, align 8
  %16 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t9, i64 0, i32 2
  store i32 0, i32* %16, align 8
  %17 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t9, i64 0, i32 3
  store i8 1, i8* %17, align 4
  %pseudo10 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output11 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo10, i64 4294967295, %helper_error_t* nonnull %helper_error_t9, i64 21)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %13)
  ret i64 0

helper_merge8:                                    ; preds = %else_body
  %probe_read12 = call i64 inttoptr (i64 4 to i64 (%printf_t.0*, i32, %printf_t.0*)*)(%printf_t.0* nonnull %lookup_fmtstr_map6, i32 8, %printf_t.0* inttoptr (i64 140695077684784 to %printf_t.0*))
  %18 = getelementptr %printf_t.0, %printf_t.0* %lookup_fmtstr_map6, i64 0, i32 0
  store i64 1, i64* %18, align 8
  %pseudo13 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output14 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t.0*, i64)*)(i8* %0, i64 %pseudo13, i64 4294967295, %printf_t.0* nonnull %lookup_fmtstr_map6, i64 8)
  %19 = bitcast %printf_t.0* %lookup_fmtstr_map6 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %19)
  br label %if_end
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }

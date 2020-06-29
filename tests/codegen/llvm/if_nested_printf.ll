; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%printf_t = type <{ i64 }>

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) local_unnamed_addr section "s_kprobe:f_1" {
entry:
  %helper_error_t = alloca %helper_error_t, align 8
  %key = alloca i32, align 4
  %get_pid_tgid = tail call i64 inttoptr (i64 14 to i64 ()*)()
  %1 = icmp ugt i64 %get_pid_tgid, 42953967927295
  br i1 %1, label %if_body, label %if_end

if_body:                                          ; preds = %entry
  %get_pid_tgid3 = tail call i64 inttoptr (i64 14 to i64 ()*)()
  %.lobit = and i64 %get_pid_tgid3, 4294967296
  %true_cond4 = icmp eq i64 %.lobit, 0
  br i1 %true_cond4, label %if_body1, label %if_end

if_end:                                           ; preds = %if_body, %helper_merge, %entry
  ret i64 0

if_body1:                                         ; preds = %if_body
  %2 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %2)
  store i32 0, i32* %key, align 4
  %pseudo = tail call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %lookup_fmtstr_map = call %printf_t* inttoptr (i64 1 to %printf_t* (i64, i32*)*)(i64 %pseudo, i32* nonnull %key)
  %3 = icmp eq %printf_t* %lookup_fmtstr_map, null
  br i1 %3, label %helper_failure, label %helper_merge

helper_failure:                                   ; preds = %if_body1
  %4 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %4)
  %5 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %5, align 8
  %6 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %6, align 8
  %7 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 0, i32* %7, align 8
  %8 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %8, align 4
  %pseudo5 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo5, i64 4294967295, %helper_error_t* nonnull %helper_error_t, i64 21)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %4)
  ret i64 0

helper_merge:                                     ; preds = %if_body1
  %probe_read = call i64 inttoptr (i64 4 to i64 (%printf_t*, i32, %printf_t*)*)(%printf_t* nonnull %lookup_fmtstr_map, i32 8, %printf_t* inttoptr (i64 140695077718736 to %printf_t*))
  %9 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i64 0, i32 0
  store i64 0, i64* %9, align 8
  %pseudo6 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output7 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t*, i64)*)(i8* %0, i64 %pseudo6, i64 4294967295, %printf_t* nonnull %lookup_fmtstr_map, i64 8)
  %10 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %10)
  br label %if_end
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }

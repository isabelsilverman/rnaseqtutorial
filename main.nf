$HOSTNAME = ""
params.outdir = 'results'  


if (!params.Input_Reads){params.Input_Reads = ""} 
if (!params.Hisat2_Index){params.Hisat2_Index = ""} 
if (!params.bedFile){params.bedFile = ""} 

Channel.fromPath(params.Input_Reads, type: 'any').map{ file -> tuple(file.baseName, file) }.into{g_3_reads_g_0;g_3_reads_g_1}
Channel.value(params.Hisat2_Index).set{g_4_hisat2IndexPrefix_g_1}
g_5_bedFile_g_2 = file(params.bedFile, type: 'any') 


process Hisat2 {

publishDir params.outdir, overwrite: true, mode: 'copy',
	saveAs: {filename ->
	if (filename =~ /${name}.align_summary.txt$/) "Hisat2_Summary/$filename"
}

input:
 set val(name),file(reads) from g_3_reads_g_1
 val hisat2Index from g_4_hisat2IndexPrefix_g_1

output:
 set val(name), file("${name}.bam")  into g_1_mapped_reads_g_2
 file "${name}.align_summary.txt"  into g_1_outputFileTxt

"""
hisat2 -x ${hisat2Index} -U ${reads} -S ${name}.sam &> ${name}.align_summary.txt
  samtools view -bS ${name}.sam > ${name}.bam
"""
}


process RSeQC {

publishDir params.outdir, overwrite: true, mode: 'copy',
	saveAs: {filename ->
	if (filename =~ /RSeQC.${name}.txt$/) "RSeQC_output/$filename"
}

input:
 set val(name), file(bam) from g_1_mapped_reads_g_2
 file bed from g_5_bedFile_g_2

output:
 file "RSeQC.${name}.txt"  into g_2_outputFileTxt

"""
read_distribution.py  -i ${bam} -r ${bed}> RSeQC.${name}.txt
"""
}


process FastQC {

publishDir params.outdir, overwrite: true, mode: 'copy',
	saveAs: {filename ->
	if (filename =~ /.*.html$/) "FastQC_output/$filename"
}

input:
 set val(name),file(reads) from g_3_reads_g_0

output:
 file "*.html"  into g_0_outputFileHTML

"""
fastqc ${reads}
"""
}


workflow.onComplete {
println "##Pipeline execution summary##"
println "---------------------------"
println "##Completed at: $workflow.complete"
println "##Duration: ${workflow.duration}"
println "##Success: ${workflow.success ? 'OK' : 'failed' }"
println "##Exit status: ${workflow.exitStatus}"
}
